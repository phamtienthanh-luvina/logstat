#$LOAD_PATH.insert(0, 'D:/wiperdog/gemdir/win32-eventlog-0.6.0/lib', 'D:/wiperdog/gemdir/jruby-win32ole-0.8.5/lib')
$LOAD_PATH.unshift('D:/wiperdog/gemdir/win32-eventlog-0.6.0/lib') unless $LOAD_PATH.include?('D:/wiperdog/gemdir/win32-eventlog-0.6.0/lib')
$LOAD_PATH.unshift('D:/wiperdog/gemdir/jruby-win32ole-0.8.5/lib') unless $LOAD_PATH.include?('D:/wiperdog/gemdir/jruby-win32ole-0.8.5/lib')

class ProcessInput
	##
	 # getInputData: get configurarion and raw data
	 # @param conf
	 # @return inputMap
	##
	def getInputData(input_conf)
		if (input_conf['input_type'] == 'file')
			getDataFromFile(input_conf['input_source'],input_conf['start_pos'])
		elsif (input_conf['input_type'] == 'eventlog')
			getEventLog(input_conf['record_number_from'],input_conf['record_number_to'])
		elsif (input_conf['input_type'] == 'osinfo')
			getDataWin32Process()
		end
	end
	
	def getDataFromFile(source_file,start_pos)
		list_logs = Array.new
		File.foreach(source_file).with_index do |line, line_num|		
				if(line_num >= start_pos ) 
					list_logs << line
				end				 
		end
		return list_logs
	end
	
	def getEventLog(recordNumberFrom, recordNumberTo)
		#$LOAD_PATH.insert(0,'D:/wiperdog/gemdir/win32-eventlog-0.5.3/lib')
		require 'win32/eventlog'
		
		lstEventLog = Array.new
		Win32::EventLog.read('Application') do |log|
			if (log['record_number'] >= recordNumberFrom && log['record_number'] <= recordNumberTo)
				lstEventLog << log
				puts log
			end
		end
		puts "aaaa"
		puts lstEventLog
	end
	
	def getDataWin32Process()
		require 'jruby-win32ole'
		
		wmi = WIN32OLE.connect("winmgmts://")
		processes = wmi.ExecQuery("select * from win32_process")
		list_logs = Array.new
		for process in processes do
			tmpProcess = "Name:" + process.Name
			list_logs << tmpProcess
		end
		return list_logs
	end
	
	def getDataFromStream(source_file)
		
	end
end