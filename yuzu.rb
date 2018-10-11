class Yuzu
  def initialize
    ENV['TZ'] = 'Asia/Tokyo'
    @keywords = {}
    File.open("yuzu_keywords.txt", 'r') do |f|
      f.each_line do |line|
        s = line.split(",")
        @keywords[s[0]] = s[1].chomp
      end
    end

    @fallback_words = []
    File.open("yuzu_fallback_words.txt", 'r') do |f|
      f.each_line do |line|
        @fallback_words << line.chomp
      end
    end
  end

  def current_jst_time
    Time.now.to_s.gsub(" +0900", "")
  end

  def user_screen_name
    "yuzu_amechan"
  end

  def user_name_actived
    "yuzu🍬"
  end

  def user_name_sleeped
    "yuzu💤🍬"
  end

  def user_profile_link_color_actived
    "#fdc823"
  end

  def user_profile_link_color_sleeped
    "#f1c8d0"
  end

  def user_profile(client)
    "@#{client.user.screen_name}こと#{client.user.name}登場! #{client.user.description} さっきまでは、#{client.user.location}"
  end

  def login_message
    "おっまたせ〜！✌(#{current_jst_time})"
  end

  def logout_message
    "しょぼ〜ん💔(#{current_jst_time})"
  end

  def login_status_message
    "柚子、登場！☀(#{current_jst_time})"
  end

  def logout_status_separator
    "💤"
  end

  def logout_status_message
    "お布団の中#{logout_status_separator}(#{current_jst_time})"
  end

  def replace_command(message, tweet)
    message.gsub("</user_name>", tweet.user.name)
  end

  def reply_message(tweet)
    received_message = tweet.text.gsub("@#{user_screen_name}","").strip
    base_message = reply_message_from_received_message(received_message)
    formatted_message = replace_command(base_message, tweet)
    "@#{tweet.user.screen_name} #{formatted_message}"
  end

  def reply_message_from_received_message(received_message)
    # 部分一致とかも入れたほうが良いかもしれない
    return @keywords[received_message] if @keywords.key?(received_message)
    @fallback_words.sample
  end
end

return unless $0 == __FILE__

yuzu = Yuzu.new
p yuzu.login_message
received_message = ARGV[0]
reply_message = yuzu.reply_message_from_received_message(received_message)
p "#{received_message} -> #{reply_message}"
p yuzu.logout_message
