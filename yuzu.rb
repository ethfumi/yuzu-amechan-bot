class Yuzu
  def initialize
    ENV['TZ'] = 'Asia/Tokyo'
    @keywords = {}
    File.open("yuzu_keywords.txt", 'r') do |f|
      f.each_line do |line|
        next if /^(\n|#)/ =~ line 
        s = line.split(",", 2)
        @keywords[s[0]] = s[1].chomp.split("\t")
      end
    end

    @fallback_words = []
    File.open("yuzu_fallback_words.txt", 'r') do |f|
      f.each_line do |line|
        next if /^(\n|#)/ =~ line 
        @fallback_words << line.chomp
      end
    end
  end

  def current_jst_time
    Time.now.to_s.gsub(" +0900", "")
  end

  def profile_actived
    {
      name: "yuzu🍬",
      location: "柚子、登場！☀(#{current_jst_time})",
      profile_link_color: "#fdc823"
    }
  end

  def profile_sleeped
    {
      name: "yuzu💤🍬",
      location: logout_status_message,
      profile_link_color: "#f1c8d0"
    }
  end

  def set_maintenance_status
    @maintenance = true
  end

  def maintenance_mark
    "💓"
  end

  def user_profile(client)
    "@#{client.user.screen_name}こと#{client.user.name}登場! #{client.user.description} さっきまでは、#{client.user.location}"
  end

  def login_message
    "おっまたせ〜！✌(#{current_jst_time})"
  end

  def error_message
    "しょぼ〜ん💔(#{current_jst_time})"
  end

  def logout_message
    "まったね〜。ばいばーい🍭(#{current_jst_time})"
  end

  def logout_status_separator
    "💤"
  end

  def logout_status_message
    "お布団の中#{logout_status_separator}(#{current_jst_time})#{@maintenance ? maintenance_mark : ""}"
  end

  def replace_command(message, tweet)
    message.gsub("</user_name>", tweet.user.name)
  end

  def reply_message(tweet)
    received_message = tweet.text.gsub(/@\w+/,"").strip
    base_message = reply_message_from_received_message(received_message)
    formatted_message = replace_command(base_message, tweet)
    "@#{tweet.user.screen_name} #{formatted_message}"
  end

  def reply_message_from_received_message(received_message)
    found_key = @keywords.keys.find{|key| /#{key}/ === received_message }
    return @keywords[found_key].sample if found_key

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
