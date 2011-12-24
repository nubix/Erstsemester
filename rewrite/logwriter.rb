class LogWriter
	def writeLog input
		return unless LOG
		
		fh = File.open("logs/"+Time.now.to_s.split[0], "a+")
		unless input.nil? then
			fh.puts input 
			fh.flush
		end
		fh.close
	end
end