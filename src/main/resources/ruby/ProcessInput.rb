require 'ruby/libs/Common.rb'

include CommonUtils

class ProcessInput
  ##
  # getInputData: get raw logs data
  # @param conf
  # @return listLogs;
  ##
  def getInputData(input_conf, map_default_input)

    if(input_conf != nil)
      CommonUtils.require_gem("os")
      # PROCESS FILE
      if (input_conf['input_type'] == 'file')
        #get logs from logs file
        path = input_conf['path']
        if(path != nil && path != '')
          require "ruby/input/file.rb"
          # File format: plain_text, csv
          file_format = input_conf['file_format']
          if (file_format == nil || file_format == '')
            file_format = map_default_input['file_format']
          end
          # Monitor type: line, date
          monitor_type = input_conf['monitor_type']
          if (monitor_type == nil || monitor_type == '')
            monitor_type = map_default_input['monitor_type']
          end
          # Start file name
          start_file_name = input_conf['start_file_name']
          if (start_file_name == nil || start_file_name == '')
            start_file_name = map_default_input['start_file_name']
          end
          # Start position
          start_pos = input_conf['start_pos']
          if (start_pos == nil || start_pos == '')
            start_pos = map_default_input['start_pos']
          end
          # Sort type of file name
          asc_by_fname = input_conf['asc_by_fname']
          if (asc_by_fname == nil || asc_by_fname == '')
            asc_by_fname = map_default_input['asc_by_fname']
          end
          # Monitor from date
          from_date = input_conf['from_date']
          if (from_date == nil || from_date == '')
            from_date = map_default_input['from_date']
          end
          return getLogsFromFile(path, file_format, monitor_type, start_file_name, start_pos, asc_by_fname, from_date)
        else
          puts "[Logstat]: Path to logs directory is required !"
          return
        end
        # PROCESS LOG4J
      elsif (input_conf['input_type'] == 'log4j')
        #get logs from log4j via socket
        port = input_conf['port']
        if(port != nil && port != '')
          require "ruby/input/log4j.rb"
          # Time out
          timeout = input_conf['timeout']
          if (timeout == nil || timeout == '')
            timeout = map_default_input['log4j.timeout']
          end
          # Host IP
          host = input_conf['host']
          if (host == nil || host == '')
            host = map_default_input['log4j.host']
          end
          return getDataLog4j(port, timeout, host)
        else
          puts "[Logstat]:Port is required !"
          return
        end
        # PROCESS SOCKET
      elsif (input_conf['input_type'] == 'socket')
        #get logs from socket
        port = input_conf['port']
        if(port != nil && port != '')
          require "ruby/input/socket.rb"
          # Time out
          timeout = input_conf['socket.timeout']
          if (timeout == nil || timeout == '')
            timeout = map_default_input['socket.timeout']
          end
          # Host IP
          host = input_conf['host']
          if (host == nil || host == '')
            host = map_default_input['socket.host']
          end
          return getDataFromSocket(port, timeout, host)
        else
          puts "[Logstat]:Port is required !"
          return
        end
        # PROCESS EVENTLOG
      elsif (OS.windows? && input_conf['input_type'] == 'eventlog')
        require "ruby/input/event_log.rb"
        # Event log type
        event_log_type = input_conf['event_log_type']
        if (event_log_type == nil || event_log_type == '')
          event_log_type = map_default_input['event_log_type']
        end
        # Time generate
        from_time_generated = input_conf['from_time_generated']
        if (from_time_generated == nil || from_time_generated == '')
          from_time_generated = map_default_input['from_time_generated']
        end
        # Call getEventlog method
        return getEventLog(event_log_type, from_time_generated)
        # PROCESS SYSLOG
      elsif (OS.linux? && input_conf['input_type'] == 'sys_log')
        # Call getSyslog method
        require "ruby/input/sys_log.rb"
        # Path configuration
        path_conf = input_conf['path_conf']
        if (path_conf == nil || path_conf == '')
          path_conf = map_default_input['path_conf']
        end
        # Type of log
        log_type = input_conf['log_type']
        if (log_type == nil || log_type == '')
          log_type = map_default_input['log_type']
        end
        # Time generate
        from_time_generated = input_conf['from_time_generated']
        if (from_time_generated == nil || from_time_generated == '')
          from_time_generated = map_default_input['from_time_generated']
        end
        return getSyslog(path_conf, log_type, from_time_generated)
      end
    end
  end
end
