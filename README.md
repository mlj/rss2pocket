# rss2pocket

`rss2pocket` is a simple RSS to [Pocket](http://getpocket.com) pipe. It reads
RSS feeds and pushes the URL of each feed entry to a Pocket account.

## Usage

Create `config/config.yml` and add a Pocket consumer key and an access token:

    consumer_key: xxx
    access_token: xxx

Create `config/feeds.yml` and add the URLs of the feeds. The file must be
writable since it is used to store feed metadata.

    ---
    http://www.economist.com/blogs/analects/index.xml:
    http://languagelog.ldc.upenn.edu/nll/?feed=atom:

Start the app:

```sh
foreman start
```

The polling interval is hard-coded to one day.

## License

`rss2pocket` is released under the [MIT License](http://opensource.org/licenses/MIT).
