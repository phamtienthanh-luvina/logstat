#Get logs from text file(s)
#@param : path - Path to logs directory
#@param : file_format - Format of logs file (plain text or csv)
#@param : monitor_type - Type of file monitor (by line or date)
#@param : start_pos - Line number of logs in file .The logs file will be read from this position
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@return list_logs - a list of logs string
def getLogsFromFile(path,file_format=nil,monitor_type=nil,start_file_name=nil,start_pos=nil,asc_by_fname=nil,from_date=nil)
  require "ruby/input/file_plaintext.rb"
  require "ruby/input/file_csv.rb"

  list_logs = nil
  if(monitor_type == nil)
    monitor_type = "line"
  end
  if(start_pos == nil)
    start_pos = 0
  end
  if(file_format == nil)
    file_format = "plain_text"
  end
  if(file_format == 'plain_text')
    if(monitor_type == 'line')
      list_logs = getLogsByLine(path,start_file_name,start_pos,asc_by_fname)
    elsif (monitor_type == 'date')
      list_logs = getLogsByDate(path,start_file_name,from_date,asc_by_fname)
    end
  elsif(file_format == 'csv')
    if(start_file_name != nil)
      file_ext = File.extname(File.join(path,start_file_name))
      if(file_ext != ".csv")
        puts "[Logstat]  : Incorrect csv file : #{start_file_name}"
        return
      end
    end
    if(monitor_type == 'line')
      list_logs = getLogsCSVByLine(path,start_file_name,start_pos,asc_by_fname)
    elsif(monitor_type == 'date')
      list_logs = getLogsCSVByDate(path,start_file_name,from_date,asc_by_fname)
    end
  end
  return list_logs
end
