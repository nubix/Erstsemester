def sendTweet
	Twitter.configure do |config|
		config.consumer_key = YOUR_CONSUMER_KEY
		config.consumer_secret = YOUR_CONSUMER_SECRET
		config.oauth_token = YOUR_OAUTH_TOKEN
		config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
	end
	client = Twitter::Client.new
	client.update("Whuuut?")
end

def handleCommand input
	msg = input.slice(input.split(':')[1].length + 2, input.length)
	return unless msg.start_with?(ADMPASS)

	msg = msg.slice(ADMPASS.length, msg.length)
	p msg if DEBUG
	SOCK.puts msg
end

def punktemagie input, nickname
	return unless input.start_with?('.') or input.start_with?(NICK+": ")

	if input.split.size == 1 and input.split[0] == "..." then
		msg = "0"
	elsif input.split(".").size == 3 and
		  input.split(".")[1] == input.split(".")[2] and
		  input.split(".")[0].empty? then
		msg = input.split(".")[1].length.to_s
	end

	if input.delete!(NICK+": ") then
		if input.to_i > 20 then
			input = 20
		end
		spaces = ""
		input.to_i.times do
			spaces += " "
		end             
		msg = "."+spaces+"."+spaces+"."
	end                              
												
	SOCK.puts "PRIVMSG "+CHANNEL+" :"+nickname + ": " + msg 
end