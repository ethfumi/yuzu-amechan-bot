class Yuzu
  def initialize
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

  def replace_command(message, tweet)
    message.gsub("</user_name>", "tweet.user.name")
  end

  def reply_message(tweet)
    received_message = tweet.text.gsub("@yuzu_amechan","").strip
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
received_message = ARGV[0]
reply_message = yuzu.reply_message_from_received_message(received_message)
p "#{received_message} -> #{reply_message}"