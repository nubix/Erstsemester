### configure the bot here ###
NICK = 'ErstiBetabot'
NAME = 'Neuer'
CHANNEL = '##meh'
ADMPASS = ''

HOST = 'irc.freenode.net'
PORT = 6666

LOG = false
VERBOSE = true
DEBUG = true
#Twitter oAuth 
TWITTER_TO = '@fgraum'
YOUR_CONSUMER_KEY = 'kOVgSUKQZBe65zpAs6Mw'
YOUR_CONSUMER_SECRET = '2kMQ6vkw2AyvOWUnPrCcJvuKJM5NQhiKPGZgNdPsH0'
YOUR_OAUTH_TOKEN = '2kMQ6vkw2AyvOWUnPrCcJvuKJM5NQhiKPGZgNdPsH0'
YOUR_OAUTH_TOKEN_SECRET = 'flW2DqbRH5FnYJrjdajzk9veX1qM7c9PqUCbs1TlNM'
### end config ###

require 'twitter'
require 'socket'
require 'time'
require 'kconv'

def sayHello sock
	sock.puts 'USER '+NICK+' * irc.freenode.net :'+NAME
	sock.puts 'NICK '+NICK
	sock.puts 'JOIN '+CHANNEL
end



###MAIN 
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
