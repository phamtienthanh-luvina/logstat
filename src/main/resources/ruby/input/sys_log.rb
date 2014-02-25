
##
# getSyslog: get syslog data (linux)
# @param syslog_config_file_path
# @param log_type:
# @param from_time:
# @return listSyslog
##
def getSyslog(syslog_config_file_path, log_type, from_time)
  # GET INPUT INFORMATION RECEIVE FROM JOB
  # Log Type
  logType = "syslog"
  if log_type != nil && log_type != ''
    logType = log_type
  end
  # Time start monitor
  fromTime = 0
  if from_time != nil && from_time != ''
    fromTime = DateTime.parse(from_time).strftime("%s").to_i
  end
  # Default directory of log file
  logDir = '/etc/syslog.conf'
  if syslog_config_file_path != nil && syslog_config_file_path != ''
    logDir = syslog_config_file_path
  end

  # PROCESS SYSLOG CONFIGURATION
  mapSyslogConfig = Hash.new
  listSyslog = Array.new
  exitsLogType = false
  File.foreach(logDir) { |lineDir|
    unless lineDir.chomp.empty?
      unless lineDir.include? '#'
        if lineDir.include? logType
          exitsLogType = true
          correspondingFile = lineDir.split(" ")[1]
          # GET DATA INPUT
          File.foreach(correspondingFile) { |line|
            regxDate = "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{2} \\d{2}:\\d{2}:\\d{2}"
            logTime = DateTime.parse(line.match(regxDate).to_s).strftime("%s").to_i
            if (logTime >= fromTime)
              listSyslog << line
            end
          }
        end
      end
    end
  }
  if exitsLogType == false
    File.foreach(logDir) { |lineDir|
      if lineDir.include? "logdir"
        lstLogDir = lineDir.split(" = ")
        correspondingFile = "#{lstLogDir[1]}/#{logType}.log"
        # GET DATA INPUT
        File.foreach(correspondingFile) { |line|
          regxDate = /\A((\d{1,2}[-\/]\d{1,2}[-\/]\d{4})|(\d{4}[-\/]\d{1,2}[-\/]\d{1,2}))/
          logTime = DateTime.parse(line.match(regxDate).to_s).strftime("%s").to_i
          if (logTime >= fromTime)
            listSyslog << line
          end
        }
      end
    }
  end
  return listSyslog
end