### configure the bot here ###
NICK = 'Erstsemester'
NAME = 'Neuer'
CHANNEL = '##cs-studs'
ADMPASS = 'passwort@'

HOST = 'irc.freenode.net'
PORT = 6666


FGRAUM_IP='134.169.35.234'
FGRAUM_PORT=1337

LOG = true
VERBOSE = false
DEBUG = false
### end config ###

require 'socket'
require 'time'
require 'kconv'

def fgraum nick, msg
	return unless msg.start_with?('!fgraum') or (CHANNEL + nick.length + msg.sub("!fgraum ", "").length) < 120

	begin
		fgsocket = TCPSocket.open(FGRAUM_IP, FGRAUM_PORT)
		p "fgraum socket auf" if DEBUG
		fgsocket.puts (" " + CHANNEL + " <" + nick + "> " + msg.sub("!fgraum ",""))
		p CHANNEL + " <" + nick +"> "+ msg.sub("!fgraum ","") if DEBUG
	ensure
		fgsocket.close unless fgsocket.nil?
	end
end

def sayHello sock
	sock.puts 'USER '+NICK+' * irc.freenode.net :'+NAME
	sock.puts 'NICK '+NICK
	sock.puts 'JOIN '+CHANNEL
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

def parseMessage input
	action = input.split[1]
	nickname = input.split(':')[1].split('!')[0]
	payload = input.slice(input.split(' :')[0].length + 2, input.length - input.split(' :')[0].length + 2) unless input.split(' :').nil?

	msg	= ''
	case input.split[1]
	when 'PRIVMSG'
		if input.split[2] == CHANNEL then
	#		punktemagie payload, nickname
			if payload.start_with?(["\x01"][0]+'ACTION') then
				msg += '* ' + nickname + payload.delete(["\x01"][0]).delete(["\x01"][0]+'ACTION')
			else
				fgraum nickname, payload
				msg += '<'+nickname+'> ' + payload
			end
		elsif input.split[2] == NICK then
	#		handleCommand input
#			fgraum nickname, payload		
		end
	when 'TOPIC'
		msg += "! " + nickname  + " has changed the topic: " + payload
	when 'JOIN'
		msg += "! " + nickname + " has joined."
	when 'PART'
		msg += "! " + nickname + " has left the channel."
		msg += " (" + payload + ")" unless payload.nil? or payload.empty?
	when 'QUIT'
		msg += "! " + nickname + " has quit."
		msg += " (" + payload + ")" unless payload.empty?
	when 'KICK'
		msg += "! " + input.split[3] + ' got kicked by ' + nickname
		msg += " (" + payload + ")" unless payload.empty?
	when 'NICK'
		msg += "! " + nickname + " is now known as " + payload
	when '353' ## NAMES List
		msg += "! Users in channel: " + payload.split.sort.join(' ')
	end
	
	unless msg.empty?
		msg = "[" + Time.now.to_s.split[1] + "] " + msg
		p msg if VERBOSE
		return msg
	end
end

def writeLog input
	return unless LOG
	
	fh = File.open("logs/"+Time.now.to_s.split[0], "a+")
	unless input.nil? then
		fh.puts input
		fh.flush
	end
	fh.close
end

###MAIN 
while 1
begin 
	SOCK = TCPSocket.open(HOST, PORT)
	sayHello SOCK

	#Dont forget to do the encoding right
	while line = SOCK.gets.chop
		begin
			SOCK.puts 'PONG' if line.start_with? 'PING'
			p line if DEBUG
			writeLog parseMessage line
		rescue Exception=>e
			p Time.now
			p e
			p e.backtrace
		end
	end
rescue Exception=>e
	p Time.now
	p e
	p e.backtrace
ensure
	SOCK.puts 'QUIT :Leaving for good.'
	SOCK.close
end
end
