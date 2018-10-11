require 'twitter'
require 'dotenv'
require './yuzu'

Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['MY_CONSUMER_KEY']        #Consumer Key (API Key)
  config.consumer_secret     = ENV['MY_CONSUMER_SECRET']     #Consumer Secret (API Secret)
  config.access_token        = ENV['MY_ACCESS_TOKEN']        #Access Token
  config.access_token_secret = ENV['MY_ACCESS_TOKEN_SECRET'] #Access Token Secret
end

def get_new_mention_timeline(client, prev_check_time)
  client.mentions_timeline.select{|t| t.created_at > prev_check_time}
end

# 15分に75回までの制約あり。余裕を持って+1秒してる
# https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-mentions_timeline.html
interval = (60 * 15 / 75) + 1
prev_check_time = Time.now.getutc - interval
yuzu = Yuzu.new
login_message = yuzu.login_message
client.update(login_message)
p login_message

begin
  while true
    p "さってと…#{prev_check_time + 60 * 60 * 9}からの新しいリプライなにか飛んで来てないかな〜？"

    tweets = get_new_mention_timeline(client, prev_check_time)
    prev_check_time = Time.now.getutc

    tweets.each do |t|
      options = {'in_reply_to_status_id' => t.id}
      message = yuzu.reply_message(t)
      p "#{t.user.name}[ID:#{t.user.screen_name}]#{t.text}(#{t.created_at})に対しての返信「#{message}」を#{prev_check_time}に行いました。"
      client.update(message, options)
    end

    p "#{interval}秒後にまたチェックするよー"
    sleep(interval)
  end
ensure
  logout_message = yuzu.logout_message
  client.update(logout_message)
  p logout_message
end
