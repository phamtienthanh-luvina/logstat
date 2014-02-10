class ProcessOutput
	def toFile(destination,input)
		begin
			File.open(destination, 'a') do |file|
				input.each do |line|
					file.puts line
				end	
			end
		rescue Exception => e
			puts e
		end
	end
	
	def toStream(input)
	#write input to stream
	end
	
	def toAnyWhere(input)
	#write input to AnyWhere
	end
	def output(data,conf)
		puts data 
		puts conf
		#if conf output to file
		if(conf['type'] == "file")
			self.toFile(conf['destination'],data)
		end
		#if conf output to Stream
		#self.toStream(data)
	end
end
