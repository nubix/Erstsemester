### configure the bot here ###
NICK = 'asdads'
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

#require 'twitter'
require 'socket'
require 'time'
require 'kconv'
require 'ircclient'
require 'commands'

meh = IrcClient.new(NICK, CHANNEL, HOST, PORT)
test = Thread.new {
						meh.connect
					}
sleep 10
meh.disconnect
test.join