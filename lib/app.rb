require_relative 'feed_db'
require 'pocket'

module PocketFetcher
  def self.run(&block)
    cache = Cache.new('config/feeds.yml')

    cache.each_url do |url|
      Feed.new(url, cache).fetch do |entry|
        yield entry.url
      end

      cache.save
    end
  end
end

config = YAML::load(File.open('config/config.yml'))
pocket_client = ::Pocket.client access_token: config['access_token'],
  consumer_key: config['consumer_key']

while true
  PocketFetcher.run do |url|
    pocket_client.add url: url
  end

  sleep 60 * 60 * 3
end
