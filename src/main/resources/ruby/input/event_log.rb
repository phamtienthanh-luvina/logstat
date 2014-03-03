##
# getEventLog: get eventlog viewer (windows)
# @param event_log_type: Application(default), ODiag, OSession, Security, System, ...
# @param from_time_generated: time generated
# @return lstEventLog
##
def getEventLog(event_log_type, from_time_generated)
  require_gem('jruby-win32ole')
  # Log type of eventlog
  logType = 'Application' # default
  if event_log_type != nil && event_log_type != ''
    logType = event_log_type
  end
  # Time generated
  fromTimeGenerated = 0 # default
  if from_time_generated != nil && from_time_generated != ''
    begin
      fromTimeGenerated = DateTime.parse(from_time_generated).strftime("%s").to_i
    rescue Exception => ex
      puts "[Logstat] : Incorrect date : '#{from_time_generated}'  "
      return
    end
  end
  wmi = WIN32OLE.connect("winmgmts://")
  wmi_query = ""
  if(OS.bits == 32)
    #Get data from 32 bits OS platform
    wmi_query  = "select * from Win32_NTLogEvent where Logfile = '#{logType}'"
  else
    #Get data from 64 bits OS platform
    wmi_query  = "Select * from __InstanceCreationEvent Where TargetInstance ISA 'Win32_NTLogEvent' And (TargetInstance.LogFile = '#{logType}')"
  end

  lstEventLog = Array.new
  begin
    events = wmi.ExecQuery(wmi_query)
    events.each do |event|      
      eventTimeGenerate = DateTime.parse(event.TimeGenerated.split(".")[0]).strftime("%s").to_i      
      if(eventTimeGenerate >= fromTimeGenerated)
        tmpEvent = Hash.new
        tmpEvent["source_name"] = event.SourceName
        if(event.EventType == 1)
          tmpEvent["type"] = "ERROR"
        elsif(event.EventType == 2)
          tmpEvent["type"] = "WARNING"
        elsif(event.EventType == 3)
          tmpEvent["type"] = "INFORMATION"
        elsif(event.EventType == 4)
          tmpEvent["type"] = "SERCURITY AUDIT SUCCESS"
        elsif(event.EventType == 5)
          tmpEvent["type"] = "SERCURITY AUDIT FAILURE"
        end
        tmpEvent["time"] = event.TimeGenerated
        tmpEvent["message"] = event.Message
        lstEventLog <<  tmpEvent
      end
    end
  end
  return lstEventLog
end
