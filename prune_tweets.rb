#!/usr/bin/env ruby -ws

$y ||= false # yes, actually delete
$V ||= false # verboser, show kept & deleted tweets
$v ||= $V    # verbose, show deleted tweets

require "isolate"
Isolate.now! name:"prune_tweets-2021-01-23", system:false do
  gem "twitter"
end

$-w = nil
require "twitter" # you suck, or rather, your dependencies suck
$-w = true

require "json"
require "yaml"

# things you must configure

TWITTER_USER      = "the_zenspider"
MAX_AGE_IN_DAYS   = 365 # anything older than this is deleted
FAVE_THRESHOLD    = 5
RETWEET_THRESHOLD = 5

keep_path = File.expand_path "~/.twitter.keep.yml"
keep = YAML.load File.read keep_path if File.exist? keep_path
keep ||= []
IDS_TO_SAVE_FOREVER = keep

### you shouldn't have to change anything below this line ###

TWEETS_PER_REQUEST = 200
MAX_AGE_IN_SECONDS = MAX_AGE_IN_DAYS*24*60*60
NOW_IN_SECONDS = Time.now

trc_config = YAML.load File.read File.expand_path "~/.trc"
trc_config = trc_config["profiles"][TWITTER_USER].values.first

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = trc_config["consumer_key"]
  config.consumer_secret     = trc_config["consumer_secret"]
  config.access_token        = trc_config["token"]
  config.access_token_secret = trc_config["secret"]
end

tweets = []

got_tweets = true
oldest_tweet_id = 9_000_000_000_000_000_000

# :since_id            = Returns results with an ID newer than the specified ID.
# :max_id              = Returns results with an ID older than the specified ID.
# :count               = Specifies the number of records to retrieve. max:200.
# :trim_user           = Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
# :exclude_replies     = This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
# :contributor_details = Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
# :include_rts         = Specifies that the timeline should include native retweets in addition to regular tweets. Note: If you're using the trim_user parameter in conjunction with include_rts, the retweets will no longer contain a full user object.

while got_tweets do
  $stderr.print "."
  begin
    new_tweets = client.user_timeline(TWITTER_USER,
                                      :count            => TWEETS_PER_REQUEST,
                                      :max_id           => oldest_tweet_id,
                                      :include_entities => false,
                                      :include_rts      => true)

    # new_tweets = client.retweeted_by_me count:200

    got_tweets = ! new_tweets.empty?

    if got_tweets then
      oldest_tweet_id = new_tweets.last.id - 1
      tweets += new_tweets
    end
  rescue Twitter::Error::TooManyRequests => e
    warn "Hit the rate limit; pausing for #{e.rate_limit.reset_in} seconds"
    sleep e.rate_limit.reset_in
    retry
  rescue Twitter::Error::NotFound => e
    warn "already deleted, skipping"
    f.puts tweet[:id]
  rescue StandardError => e
    warn e.inspect
    warn tweets.find { |t| t["id"] == tweet[:id] }.pretty_inspect
    warn "skipping"
    skipped += 1
  end
end if tweets.empty?
$stderr.puts "done"

deleted = 0
skipped = 0
kept    = 0

tweets.reverse_each do |tweet|
  tweet_age = NOW_IN_SECONDS - tweet.created_at

  keep = (tweet_age < MAX_AGE_IN_SECONDS         or
          IDS_TO_SAVE_FOREVER.include?(tweet.id) or
          (!tweet.retweet? and
           (tweet.favorite_count >= FAVE_THRESHOLD or
            tweet.retweet_count >= RETWEET_THRESHOLD)))

  # (tweet.retweet && !tweet.user.screen_name != TWITTER_USER) or

  break if keep && tweet_age < MAX_AGE_IN_SECONDS

  if keep then
    kept += 1

    warn "Keeping %d: %d days / %d fav / %d ret: %p" %
      [tweet.id,
       tweet_age / 86_400,
       tweet.favorite_count,
       tweet.retweet_count,
       tweet.text] if $V
    next
  end

  client.destroy_status tweet.id if $y
  deleted += 1

  if $v then
    warn "Deleted %d: %d days / %d fav / %d ret: %s%p" %
      [tweet.id,
       tweet_age / 86_400,
       tweet.favorite_count,
       tweet.retweet_count,
       $y ? "" : "(FAKE) ",
       tweet.text,
      ]
  else
    warn "Deleted %d: %d days %s" %
      [tweet.id,
       tweet_age / 86_400,
       $y ? "" : "(FAKE)"]
  end
rescue Twitter::Error::TooManyRequests => e
  warn "Hit the rate limit; pausing for #{e.rate_limit.reset_in} seconds"
  sleep e.rate_limit.reset_in
  retry
rescue StandardError => e
  warn e.inspect
  exit 1
end

warn "Deleted %d, skipped %d, kept %d" % [deleted, skipped, kept]
