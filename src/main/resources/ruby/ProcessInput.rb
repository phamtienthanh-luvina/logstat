require 'ruby/raw_process/ProcessConfig'
require 'ruby/raw_process/ProcessFile'
class ProcessInput
	##
	 # getInputData: get configurarion and raw data
	 # @param conf
	 # @return inputMap
	##
	def getInputData(input_conf)
		puts input_conf
			if (input_conf['input_type'] == 'file')
				getDataFromFile(input_conf['input_source'],input_conf['start_pos'])
			end
			
	end
	
	def getDataFromFile(source_file,start_pos)
		list_logs = Array.new
		File.foreach(source_file).with_index do |line, line_num|		
				puts line_num
				if(line_num >= start_pos ) 
					list_logs << line
				end				 
		end
		return list_logs
	end

	
	def getDataFromStream(source_file)
		
	end
end
	