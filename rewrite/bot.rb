#!/usr/bin/env ruby
### configure the bot here ###

NICK 	= 'x41414141'
NAME	= 'Neuer'
CHANNEL	= '##meh'
ADMPASS	= ''

NICKAUTH = ''

HOST	= 'irc.freenode.net'
PORT	= 6666

LOG		= true
LOGDIR = 'log/'
DEBUG	= false #true

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

#
# Checking if logdir exists and creating if not
#
if LOG && !File.directory?(LOGDIR)
	Dir.mkdir(File.join(Dir.pwd, LOGDIR), 0644)
end

a = Thread.new {
			client = IrcClient.new(NICK, CHANNEL, HOST, PORT, LOGDIR)
			client.nickauth = NICKAUTH unless NICKAUTH.nil?
			client.connect	
	}

begin
	a.join
rescue Interrupt
	print "Going down."
end
