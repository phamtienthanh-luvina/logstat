require 'ruby/ProcessInput'

ProcessInputObj = ProcessInput.new
##
 # ProcessFilter: process raw log data
##
class ProcessFilter
	##
	 # filter: process raw log data
	 # @param conf: path to configuration file
	 # @return listFinal: list log data after process filter 
	##
	def filter(list_logs,filter_exp)
		resultData = Array.new
		list_logs.each do |line|
			tmpMapResult = Hash.new
			filter_exp.each do |key,value|
					strMatch = line.match(/#{value.strip}/).to_s
					tmpMapResult[key.strip] = strMatch
					line = line.sub(strMatch, '')
			end
			tmpMapResult['message'] = line.strip
			resultData << tmpMapResult
		end
		return resultData
	end
end