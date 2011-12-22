require 'socket'
require 'thread'

class IrcClient
	attr_reader :nickname, :channel, :server, :port, :socket
	attr_accessor :queue

	def initialize (nickname, channel, server, port)
		@nickname = nickname
		@channel = channel
		@server = server
		@port = port
		@queue = Queue.new
	end

	def connect
		begin
			@socket = TCPSocket.open(@server, @port)
			@socket.puts 'USER '+@nickname+' * irc.freenode.net :'+@nickname
			@socket.puts 'NICK '+@nickname
			@socket.puts 'JOIN '+@channel

			#Dont forget to do the encoding right
			while line = @socket.gets.chop
				begin
					@socket.puts 'PONG' if line.start_with? 'PING'
					p line if DEBUG
					retString = parseMessage line
					@queue.push retString unless retString.nil?
				rescue Exception=>e
					puts "<Time="+Time.now.to_s + "> " + e.to_s + " " + e.backtrace.to_s
				end
			end
		rescue Exception=>e
			puts "<Time="+Time.now.to_s + "> " + e.to_s + " " + e.backtrace.to_s
		ensure
			disconnect
		end
	end

	def disconnect
		if !@socket.nil?
			@socket.close
			@socket = nil
		end
	end

	def parseMessage input
		action = input.split[1]
		nickname = input.split(':')[1].split('!')[0]
		payload = input.slice(input.split(' :')[0].length + 2, input.length - input.split(' :')[0].length + 2) unless input.split(' :').nil?

		msg	= ''
		case input.split[1]
		when 'PRIVMSG'
			if input.split[2] == @channel then
				if payload.start_with?(["\x01"][0]+'ACTION') then
					msg += '* ' + nickname + payload.delete(["\x01"][0]).delete(["\x01"][0]+'ACTION')
				else
					if payload.start_with?("!") then
						msg = handleCommand payload, nickname
					end
					msg += '<'+nickname+'> ' + payload
				end
			elsif input.split[2] == @nickname then
		#		handleCommand input
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
			msg = "[" + Time.now.hour.to_s + ":" + Time.now.min.to_s + ":" + Time.now.sec.to_s + "] " + msg
			p msg if VERBOSE
			return msg
		end
	end
end