require 'socket'
require 'thread'

class IrcClient
	attr_reader :nickname, :channel, :server, :port, :socket
	attr_accessor :log, :nickauth

	def initialize (nickname, channel, server, port, log=false)
		@nickname = nickname
		@channel = channel
		@server = server
		@port = port
		@log = LogWriter.new(log)if log
	end

	#
	# Creates a connection to irc-server and
	# starts the messageparser
	#
	def connect
		begin
			@socket = TCPSocket.open(@server, @port)
			@socket.puts 'USER '+@nickname+' * irc.freenode.net :'+@nickname
			@socket.puts 'NICK '+@nickname
			if @nickauth 
				@socket.puts "PRIVMSG NickServ :identify "+@nickauth
				sleep 3
			end
			@socket.puts 'JOIN '+@channel

			#TODO Do the encoding right!!
			while line = @socket.gets.chop
				begin
					@socket.puts 'PONG' if line.start_with? 'PING'
					p line if DEBUG
					retString = parseMessage line
					@log.write retString if (!retString.nil? && @log)
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


	#
	# Method to close open sockets and end all running threads
	#
	def disconnect
		if !@socket.nil?
			@socket.puts "PRIVMSG "+CHANNEL+" :Good night, and good luck."
			@socket.flush
			sleep 1
			@socket.close
			@socket = nil
		end
	end


	#
	# This method unterstands what the IRC-Server sends
	# responds correctly or calls the logwriter
	#
	def parseMessage input
		action = input.split[1]
		nickname = input.split(':')[1].split('!')[0]
		msg	= ''
		unless input.split(' :').nil?
			payload = input.slice(input.split(' :')[0].length + 2, input.length - input.split(' :')[0].length + 2)
		end

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
			msg = "["+("%02d"%Time.now.hour)+":"+("%02d"%Time.now.min)+":"+("%02d"%Time.now.sec)+"] "+msg
			p msg if DEBUG
			return msg
		end
	end
end