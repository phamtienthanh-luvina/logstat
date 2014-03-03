require 'ruby/libs/Common.rb'
include CommonUtils

class ProcessInput
  ##
  # getInputData: get raw logs data
  # @param conf
  # @return listLogs;
  ##
  def getInputData(input_conf)
    if(input_conf != nil)
      CommonUtils.require_gem("os")
      if (input_conf['input_type'] == 'file')
        #get logs from logs file
        if(input_conf['path'] != nil)
          require "ruby/input/file.rb"
          return getLogsFromFile(input_conf['path'],input_conf['file_format'],input_conf['monitor_type'],input_conf['start_file_name'],input_conf['start_pos'],input_conf['asc_by_fname'],input_conf['from_date'])
        else
          puts "[Logstat]: Path to logs directory is required !"
          return
        end
      elsif (input_conf['input_type'] == 'log4j')
        
        #get logs from log4j via socket
        if(input_conf['port'] != nil )
          require "ruby/input/log4j.rb"
          return getDataLog4j(input_conf['port'],input_conf['timeout'],input_conf['host'])
        else
          puts "[Logstat]:Port is required !"
          return
        end
      elsif (input_conf['input_type'] == 'socket')
        #get logs from socket
        if(input_conf['port'] != nil)
          require "ruby/input/socket.rb"
          return getDataFromSocket(input_conf['port'],input_conf['timeout'],input_conf['host'])
        else
          puts "[Logstat]:Port is required !"
          return
        end
      elsif (OS.windows? && input_conf['input_type'] == 'eventlog')
        require "ruby/input/event_log.rb"
        # Call getEventlog method
        return getEventLog(input_conf['event_log_type'], input_conf['from_time_generated'])
      elsif (OS.linux? && input_conf['input_type'] == 'sys_log')
        # Call getSyslog method
        require "ruby/input/sys_log.rb"
        return getSyslog(input_conf['path_conf'], input_conf['log_type'], input_conf['from_time_generated'])
      end
    end
  end
end
