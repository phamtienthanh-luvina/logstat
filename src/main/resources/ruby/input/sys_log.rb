##
# getSyslog: get syslog data (linux)
# @param syslog_config_file_path
# @param log_type:
# @param from_time:
# @return listSyslog
##
def getSyslog(syslog_config_file_path, log_type, from_time)
  # Time start monitor
  fromTime = 0
  if from_time != nil && from_time != ''
    begin
      fromTime = DateTime.parse(from_time).strftime("%s").to_i
    rescue Exception => e
      puts "[Logstat]: Invalid date : #{from_time}"
      return
    end
  end
  if(log_type.nil?)
    puts "[Logstat]: Log type is required !"
    return
  end
  if(syslog_config_file_path.nil?)
    puts "[Logstat]: Path to syslog is required !"
    return
  elsif(!File.exist?(syslog_config_file_path))
    puts "[Logstat]: Path to syslog is not avaiable !"
    return
  end
  persist_from_time = from_time
  # PROCESS SYSLOG CONFIGURATION
  mapSyslogConfig = Hash.new
  listSyslog = Array.new
  exitsLogType = false
  File.foreach(syslog_config_file_path) { |lineDir|
    unless lineDir.chomp.empty?
      unless lineDir.include? '#'
        if lineDir.include? log_type
          exitsLogType = true
          correspondingFile = lineDir.split(" ")[1]
          # GET DATA INPUT
          File.foreach(correspondingFile) { |line|
            regxDate = "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{2} \\d{2}:\\d{2}:\\d{2}"
            logTime = DateTime.parse(line.match(regxDate).to_s).strftime("%s").to_i
            if (logTime >= fromTime)
              persist_from_time = line.match(regxDate).to_s
              listSyslog << line
            end
          }
        end
      end
    end
  }
  if exitsLogType == false
    File.foreach(syslog_config_file_path) { |lineDir|
      if lineDir.include? "logdir"
        lstLogDir = lineDir.split(" = ")
        correspondingFile = "#{lstLogDir[1]}/#{log_type}.log"
        # GET DATA INPUT
        File.foreach(correspondingFile) { |line|
          regxDate = /\A((\d{1,2}[-\/]\d{1,2}[-\/]\d{4})|(\d{4}[-\/]\d{1,2}[-\/]\d{1,2}))/
          logTime = DateTime.parse(line.match(regxDate).to_s).strftime("%s").to_i
          if (logTime >= fromTime)
            persist_from_time = line.match(regxDate).to_s
            listSyslog << line
          end
        }
      end
    }
  end
  finalData = Hash.new
  persist_data = Hash.new
  persist_data["from_time"] = persist_from_time
  finalData["list_logs"] = listSyslog
  finalData["persistent_data"] = persist_data
  return finalData
end
