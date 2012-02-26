### configure the bot here ###

NICK 	= 'DerDieterisDergeilstea'
NAME	= 'Neuer'
CHANNEL	= '##meh'
ADMPASS	= ''

NICKAUTH = ''

HOST	= 'irc.freenode.net'
PORT	= 6666

LOG		= true
LOGDIR = 'log/'
DEBUG	= true

=begin
#Twitter oAuth 
TWITTER_TO = '@fgraum'
YOUR_CONSUMER_KEY = 'kOVgSUKQZBe65zpAs6Mw'
YOUR_CONSUMER_SECRET = '2kMQ6vkw2ApyvOWUnPrCcJvuKJM5NQhiKPGZgNdPsH0'
YOUR_OAUTH_TOKEN = '2kMQ6vkw2AyvOWUnPrCcJvuKJM5NQhiKPGZgNdPsH0'
YOUR_OAUTH_TOKEN_SECRET = 'flW2DqbRH5FnYJrjdajzk9veX1qM7c9PqUCbs1TlNM'
=end
### end config ###

#require 'twitter'
#require 'socket'
require 'time'
require 'kconv'
require 'ircclient'
require 'commands'
require 'logwriter'

client = Thread.new {
		IrcClient.new(NICK, CHANNEL, HOST, PORT, LOG).connect
	}

client.join