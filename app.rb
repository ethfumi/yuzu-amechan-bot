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

def get_last_logout_time(client, yuzu)
  Time.parse(client.user.location.split(yuzu.logout_status_separator)[1])
rescue
  Time.now
end

def utc_to_jst_message(time)
  (time + 60 * 60 * 9).to_s.gsub(" UTC", "")
end

def tweet(client, message)
  client.update(message)
  p message
end

def send_dm_to_master(client, message)
  send_dm(client, ENV['MASTER_SCREEN_NAME'], message)
end

def send_dm_self(client, message)
  send_dm(client, client.user.screen_name, message)
end

def send_dm(client, target, message)
  send_text = "#{message} #{utc_to_jst_message(Time.now.getutc)}"
  # twitter-6.2.0/lib/twitter/rest/request.rb:81:in `fail_or_return_response_body': Sorry, that page does not exist. (Twitter::Error::NotFound)
  # が出て使えない。バージョンアップ待ち
  # https://twitter.com/witch_kazumin/status/1042273975450066945

  # p "@#{target}に#{send_text}を送りました"
  # client.create_direct_message(target, send_text)

  # しかたないのでリプを送る
  tweet(client, "@#{target} #{send_text}")
end

yuzu = Yuzu.new
profile_text = yuzu.user_profile(client)
p profile_text
last_logout_time = get_last_logout_time(client, yuzu).getutc
prev_check_time = last_logout_time

# 15分に75回までの制約あり。余裕を持って+1秒してる
# https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-mentions_timeline.html
interval = (60 * 15 / 75) + 1

begin
  tweet(client, yuzu.login_message)
  client.update_profile(yuzu.profile_actived)

  p "さってと… #{utc_to_jst_message(prev_check_time)} からの新しいリプライなにか飛んで来てないかな〜？"

  while true

    tweets = get_new_mention_timeline(client, prev_check_time)
    prev_check_time = Time.now.getutc

    tweets.each do |t|
      options = {'in_reply_to_status_id' => t.id}
      message = yuzu.reply_message(t)
      p "#{t.user.name}[ID:#{t.user.screen_name}]#{t.text}(#{t.created_at})に対しての返信「#{message}」を#{prev_check_time}に行いました。"
      client.update(message, options)
    end

    # p "#{interval}秒後にまたチェックするよー"
    sleep(interval)
  end
rescue Twitter::Error::TooManyRequests => e
  tweet(client, "むぅ、電池が切れそう…#{utc_to_jst_message(e.rate_limit.reset_at)}までおやすみするねー")
  client.update_profile(yuzu.profile_sleeped)
  sleep(e.rate_limit.reset_in)
  retry
rescue => e
  send_dm_to_master(client, "エラーだよ！#{e.inspect}")
  tweet(client, yuzu.error_message)
rescue Interrupt => e
  tweet(client, yuzu.logout_message)
ensure
  client.update_profile(yuzu.profile_sleeped)
end
