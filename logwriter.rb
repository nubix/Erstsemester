=begin
This class is a multihreaded logwriter
=end

require 'thread'

class LogWriter
	attr_accessor :logdir

	def initialize logdir = "log/"
		@logdir = logdir
	end

	def write string
		@queue ||= Queue.new
		startWriteThread
		@queue << string
	end

private

	#
	# Creates never terminating thread that writes
	# everything that will be put into @queue
	#
	def startWriteThread
		return if @pushingThread

		@pushingThread = Thread.new do
			items = []

			loop do
				items << @queue.pop
				if items.size > 0

					#Formats to YYYY-MM-DD
					filename = ("%02d"%Time.now.year)+"-"+("%02d"%Time.now.month)+"-"+("%02d"%Time.now.day)

					File.open(@logdir+filename, "a+") { |f|
						f.puts items 
						f.flush
						items.clear
					}
				end
			end
		end
	end
end
