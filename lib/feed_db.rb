require 'feedjira'
require 'yaml'

class Cache
  def initialize(cache_file = 'feeds.yml')
    if File.exists?(cache_file)
      @data = YAML::load_file(cache_file)

      @data = {} unless @data
    else
      @data = {}
    end

    @cache_file = cache_file
  end

  def save
    File.open(@cache_file, 'w') { |f| f.write @data.to_yaml }
  end

  def [](url)
    @data[url] ||= {}
    @data[url]
  end

  def each_url
    @data.keys.each do |url|
      yield url
    end
  end
end

class Feed
  def initialize(url, cache)
    @state = cache[url]
    @url = url
    @parser = Feedjira::Feed
  end

  MIN_YEAR = 1970
  ONE_WEEK = 24 * 60 * 60 * 7

  def update_last_fetched(timestamp)
    @state[:last_fetched] = timestamp unless timestamp.year < MIN_YEAR
  end

  def update_latest_url(url)
    @state[:latest_url] = url
  end

  def last_fetched
    @state[:last_fetched] # || Time.now - ONE_WEEK
  end

  def latest_url
    @state[:latest_url]
  end

  def tags
    @state[:tags]
  end

  def title
    @title
  end

  def fetch
    raw_feed =
      if last_fetched
        @parser.fetch_and_parse(@url, user_agent: "Stringer", if_modified_since: last_fetched)
      else
        @parser.fetch_and_parse(@url, user_agent: "Stringer")
      end

    unless raw_feed.nil? or raw_feed == 304 or raw_feed == 0 or raw_feed == 500 or raw_feed == 200 or raw_feed == 404
      stories = []

      @title = raw_feed.title
      @feed_url = raw_feed.feed_url

      if raw_feed.last_modified && last_fetched && raw_feed.last_modified < last_fetched
      else
        raw_feed.entries.each do |story|
          break if latest_url && story.url == latest_url

          stories << story unless story.published && last_fetched && story.published < last_fetched
        end
      end

      stories.each do |story|
        yield story, tags
      end

      update_last_fetched(raw_feed.last_modified)
      update_latest_url(stories.first.url) unless stories.empty?
    end
  end
end
