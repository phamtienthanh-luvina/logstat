##
# getEventLog: get eventlog viewer (windows)
# @param event_log_type: Application(default), ODiag, OSession, Security, System, ...
# @param from_time_generated: time generated
# @return lstEventLog
##
def getEventLog(event_log_type, from_time_generated)

  #Persistent data for next monitoring
  require_gem('jruby-win32ole')
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
  persist_from_time = from_time_generated
  wmi = WIN32OLE.connect("winmgmts://")
  wmi_query = ""
  if(OS.bits == 32)
    #Get data from 32 bits OS platform
    wmi_query  = "select * from Win32_NTLogEvent where Logfile = '#{event_log_type}'"
  else
    #Get data from 64 bits OS platform
    wmi_query  = "Select * from __InstanceCreationEvent Where TargetInstance ISA 'Win32_NTLogEvent' And (TargetInstance.LogFile = '#{event_log_type}')"
  end

  lstEventLog = Array.new
  begin
    events = wmi.ExecQuery(wmi_query)
    tmp_persist = 0
    events.each do |event|
      eventTimeGenerate = DateTime.parse(event.TimeGenerated.split(".")[0]).strftime("%s").to_i
      if(eventTimeGenerate >= fromTimeGenerated)
        if(tmp_persist <= eventTimeGenerate)
          tmp_persist = eventTimeGenerate
          persist_from_time = event.TimeGenerated.split(".")[0]
        end
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
  finalData = Hash.new
  persist_data = Hash.new
  finalData["list_logs"] = lstEventLog
  persist_data["from_time"] = persist_from_time
  finalData["persistent_data"] = persist_data
  return finalData
end
