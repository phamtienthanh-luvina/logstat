#Get logs from text file(s)
#@param : path - Path to logs directory
#@param : file_format - Format of logs file (plain text or csv)
#@param : monitor_type - Type of file monitor (by line or date)
#@param : start_pos - Line number of logs in file .The logs file will be read from this position
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@return list_logs - a list of logs string
def getLogsFromFile(path,file_format,monitor_type,start_file_name,start_pos,asc_by_fname,from_date)
  require "ruby/input/file_plaintext.rb"
  require "ruby/input/file_csv.rb"
  
  #get data from plain_text file
  if(file_format == 'plain_text')
    if(monitor_type == 'line')
      return getLogsByLine(path,start_file_name,start_pos,asc_by_fname)
    elsif (monitor_type == 'date')
      return getLogsByDate(path,start_file_name,from_date,asc_by_fname)
    end
  elsif(file_format == 'csv')
    #get data from csv file
    if(start_file_name != nil)
      file_ext = File.extname(File.join(path,start_file_name))
      if(file_ext != ".csv")
        puts "[Logstat]  : Incorrect csv file : #{start_file_name}"
        return
      end
    end
    if(monitor_type == 'line')
      return getLogsCSVByLine(path,start_file_name,start_pos,asc_by_fname)
    elsif(monitor_type == 'date')
      return getLogsCSVByDate(path,start_file_name,from_date,asc_by_fname)
    end
  end
end
