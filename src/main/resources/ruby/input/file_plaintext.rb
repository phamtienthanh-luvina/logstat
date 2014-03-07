#Get logs from file(s) with single line
#@param : path - Path to logs directory
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@param : start_pos -  the line number of log line will be start to read
#@return list_logs - a list of logs string
def getLogsByLine(path,start_file_name,start_pos,asc_by_fname)

  if(start_pos.nil?)
    start_pos = 1
  else
    if(start_pos.is_a?(String))
      begin
        start_pos = start_pos.to_i
      rescue Exception => ex
        puts "[Logstat]  : Incorrect parameters : 'start_pos' must be a number !"
        return
      end
    end
  end
  persist_start_pos = start_pos
  persist_start_file_name = start_file_name
  list_logs = Array.new
  #Get data from single file
  if(asc_by_fname == nil)
    if(start_file_name == nil)
      puts "[Logstat]  : 'start_file_name' parameter must be required !"
      return
    end
    File.foreach(path+"/"+start_file_name) do |line|
      line_num = $.
      if((line.strip != "") && ( line_num >= start_pos ))
        list_logs << line
        persist_start_pos = line_num
        persist_start_file_name = start_file_name
      end
    end
  else
    #Get data from multi file

    #get list logs files sort by the modified time
    sorted_by_modified = Dir.entries(path).sort_by {|f| File.mtime(File.join(path,f))}.reject{|entry| entry == "." || entry == ".." || File.directory?(File.join(path,entry))}

    #File sort to ASC
    if(asc_by_fname == true)
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.first
      end
      Dir.entries(path).sort.each  do |log_file|
        if((log_file <=> start_file_name) >= 0)
          if File.file?(File.join(path,log_file))
            File.foreach(File.join(path,log_file)) do |line|
              line_num = $.
              if((log_file <=> start_file_name) == 0 )
                if((line.strip != "") && line_num >= start_pos)
                  list_logs << line
                end
              else
                if((line.strip != "") )
                  list_logs << line
                end
              end
              persist_start_pos = line_num
            end
            persist_start_file_name =  File.basename(log_file)
          end
        end
      end
    else
      #File sort to DESC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.last
      end
      Dir.entries(path).sort.reverse.each do |log_file|
        line_num = $.
        if File.file?(File.join(path,log_file))
          if((log_file <=> start_file_name) <= 0)
            File.foreach(File.join(path,log_file)) do |line|
              line_num = $.
              if(( start_file_name <=> log_file) == 0)
                if((line.strip != "") && line_num <= start_pos)
                  list_logs << line
                end
              else
                if((line.strip != ""))
                  list_logs << line
                end
              end
              persist_start_pos = line_num
            end
            persist_start_file_name = File.basename(log_file)
          end
        end
      end
    end
  end
  finalData = Hash.new
  persist_data = Hash.new
  persist_data["start_file_name"] = persist_start_file_name
  persist_data["start_pos"] = persist_start_pos
  finalData["list_logs"] = list_logs
  finalData["persistent_data"] = persist_data
  return finalData
end

#Get logs from file(s) with multiline seperate by date
#@param : path - Path to logs directory
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@param : from_date - the logs will be read from this time
#@return list_logs - a list of logs string
def getLogsByDate(path,start_file_name,from_date,asc_by_fname)
  require 'date'
  persist_from_date = Hash.new
  persist_start_file_name = start_file_name
  list_logs = Array.new
  if(asc_by_fname == nil)
    #Get logs from single file
    if(start_file_name == nil)
      puts "[Logstat]  : 'start_file_name' parameter must be required !"
      return
    end
    list_logs = getLogsSingleFileByDate(path,start_file_name,from_date,asc_by_fname,persist_from_date)
  else
    #Get logs from multi files
    sorted_by_modified = Dir.entries(path).sort_by {|f| File.mtime(File.join(path,f))} .reject{|entry| entry == "." || entry == ".." || File.directory?(File.join(path,entry))}
    if(asc_by_fname)
      #File sorted  ASC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.first
      end
      Dir.entries(path).sort.each  do |log_file|

        if File.file?(File.join(path,log_file))
          if((start_file_name <=> log_file) <= 0)
            list_logs.concat(getLogsSingleFileByDate(path,log_file,from_date,asc_by_fname,persist_from_date))
            persist_start_file_name = log_file
          end
        end
      end
    else
      #File sorted DESC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.last
      end
      Dir.entries(path).sort.reverse.each do |log_file|
        if File.file?(File.join(path,log_file))
          if((start_file_name <=> log_file) >= 0)
            list_logs.concat(getLogsSingleFileByDate(path,log_file,from_date,asc_by_fname,persist_from_date))
            persist_start_file_name = log_file
          end
        end
      end
    end
  end
  finalData = Hash.new
  finalData["list_logs"] = list_logs
  #Persistent data for next monitoring
  persist_data = Hash.new
  persist_data["start_file_name"] = persist_start_file_name
  persist_data["from_date"] = persist_from_date["persist_from_date"]
  finalData["persistent_data"] = persist_data
  return finalData
end

#Get logs from file with multiline seperate by date
#@param : path - Path to logs directory
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@return list_logs - a list of logs in hashes
def getLogsSingleFileByDate(path,start_file_name,from_date,asc_by_fname,persist_from_date)
  require 'date'
  logs_date = Date.new
  valid_items = nil
  if(from_date != nil)
    begin
      from_date = Date.parse(from_date)
    rescue Exception => ex
      puts "[Logstat]  : Incorrect 'from_date' parameter: #{from_date}"
      return
    end
  end
  date_regex = /\A((\d{1,2}[-\/]\d{1,2}[-\/]\d{4})|(\d{4}[-\/]\d{1,2}[-\/]\d{1,2}))/
  list_logs = Array.new
  check_log_start = false
  log_items = ""

  File.foreach(path+"/"+start_file_name) do |line|
    #check first line start with a date string
    if((line.strip != "") && (line =~ date_regex))
      str_date = line[date_regex,1]
      #check if date is validate
      begin
        logs_date = Date.parse(str_date)
        #if monitor type is date
        if(from_date != nil)
          #if monitor only 1 file or multi file with sort by ASC file name
          if(asc_by_fname == nil || asc_by_fname)                       
            if(from_date <= logs_date)
              check_log_start = true
              valid_items = true
            else
              if(valid_items)
                list_logs << log_items
              end
              valid_items = false
            end
          else
            #if monitor multi file with sort by DESC file name
            if(from_date >= logs_date)
              check_log_start = true
              valid_items = true
            else
              if(valid_items)
                list_logs << log_items
              end
              valid_items = false
            end
          end
        else
          check_log_start = true
        end
        persist_from_date["persist_from_date"] =  str_date
      rescue Exception => e
        check_log_start = false
        puts "[Logstat]  :  #{e}"
      end
    else
      check_log_start = false
    end
    #Add log_items to list_logs
    if(valid_items.nil?)
      if(check_log_start )
        if(log_items.strip != "")
          list_logs << log_items
        end
        #New logs items
        log_items = line
      else
        if(log_items.strip != "")
          log_items += line
        end
      end
    else
      #if a new logs start,and previous items is valid then add it to list log
      if(check_log_start && valid_items)
        if(log_items.strip != "")
          list_logs << log_items
        end
        #New logs items
        log_items = line
      else
        if(log_items.strip != "")
          log_items += line
        end
      end
    end
  end

  #Last items
  if(valid_items == true )
    list_logs << log_items
  end
  return list_logs
end
