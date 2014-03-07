#Get logs from csv file by line number
#@param : path - Path to logs directory
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@return list_logs - a list of logs in hashes

def getLogsCSVByLine(path,start_file_name=nil,start_pos=nil,asc_by_fname=nil)
  #set default start_pos from 2nd line  (1st line is header)
  if(start_pos.nil?)
    start_pos = 2
  else
    if(start_pos.is_a?(String))
      begin
        start_pos = start_pos.to_i
      rescue Exception => ex
        puts "[Logstat] : Incorrect parameters : 'start_pos' must be a number !"
        return
      end
    end
  end
  persist_start_pos = start_pos
  persist_start_file_name = start_file_name
  list_logs = Array.new
  require 'csv'

  if(asc_by_fname == nil)
    #Get logs from single file
    list_logs = Array.new
    if(start_file_name.nil?)
      puts "[Logstat] : Incorrect parameter : 'start_file_name' must be required if 'asc_by_fname' is obmitted "
      return
    end
    #Retrieve CSV data from csv file
    CSV.foreach(File.join(path,start_file_name), :headers => true) do |csv_obj|
      line_num = $.
      if(!csv_obj.empty? && line_num >= start_pos)
        list_logs << csv_obj.to_hash
        persist_start_pos = line_num
      end
    end
  else
    #Get logs from multi files
    sorted_by_modified = Dir.entries(path).sort_by {|f| File.mtime(File.join(path,f))}.reject{|entry| entry == "." || entry == ".." || !(entry.end_with?(".csv")) }
    if(asc_by_fname)
      #File sorted  ASC

      if(start_file_name == nil )
        #set default start_file_name by the oldest modified file
        start_file_name = sorted_by_modified.first
      end
      #Retrieve logs folder
      Dir.glob(path+"/*.csv").sort.each  do |log_file|
        #if log_file is equal or older than start_file_name then get data from this file
        if((File.join(path,start_file_name) <=> log_file ) <=0)
          CSV.foreach(log_file, :headers => true) do |csv_obj|
            line_num = $.
            if(!csv_obj.empty?)
              if((File.join(path,start_file_name) <=> log_file) == 0)
                if(line_num >= start_pos)
                  list_logs << csv_obj.to_hash
                end
              else
                list_logs << csv_obj.to_hash
              end
            end
            persist_start_pos = line_num
          end
          persist_start_file_name = File.basename(log_file)
        end
      end
    else
      #File sorted DESC
      if(start_file_name == nil )
        #set default start_file_name by the lastest modified file
        start_file_name = sorted_by_modified.last
      end
      Dir.glob(path + "/*.csv").sort.reverse.each do |log_file|
        
        #if log_file is equal or newer than start_file_name then get data from this file
        if((File.join(path,start_file_name) <=> log_file ) >=0)
          
          CSV.foreach(log_file, :headers => true) do |csv_obj|
            line_num = $.
            if(!csv_obj.empty?)
              if((File.join(path,start_file_name) <=> log_file) == 0)
                if( line_num <= start_pos)
                  list_logs << csv_obj.to_hash
                end
              else
                list_logs << csv_obj.to_hash
              end
            end
            persist_start_pos = line_num
          end
          persist_start_file_name = File.basename(log_file)
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

#Get logs from csv file by line number
#@param : path - Path to logs directory
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@return list_logs - a list of logs in hashes
def getLogsCSVByDate(path,start_file_name=nil,from_date=nil,asc_by_fname=nil)
  require 'date'
  #If from_date is nil ,get logs from current time
  if(from_date != nil)
    begin
      from_date = Date.parse(from_date)
    rescue Exception => ex
      puts "[Logstat] : Incorrect 'from_date' parameter: #{from_date}"
      return
    end
  end

  persist_from_date = from_date
  persist_start_file_name = start_file_name

  #closure for read csv from file
  list_logs = Array.new
  require 'csv'
  if(asc_by_fname == nil)
    #Get logs from single file
    if(start_file_name.nil?)
      puts "[Logstat]  : the 'start_file_name' parameter must be required  if the 'asc_by_fname' obmitted!"
      return
    end
    list_logs = Array.new
    CSV.foreach(File.join(path,start_file_name), :headers => true) do |csv_obj|
      #logs must start with a time
      if(!csv_obj.empty? )
        logs_time = Date.parse(csv_obj[0])
        if( logs_time >= from_date)
          list_logs << csv_obj.to_hash
          persist_from_date = csv_obj[0]
        end
      end
    end
  else
    #Get logs from multi files
    sorted_by_modified = Dir.entries(path).sort_by {|f| File.mtime(File.join(path,f))}.reject{|entry| entry == "." || entry == ".." || !(entry.end_with?(".csv")) }
    if(asc_by_fname)
      #File sorted  ASC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.first
      end
      Dir.glob(path+"/*.csv").sort.each  do |log_file|
        #Retrieve data from csv file and only get logs line if the logs time is equal or later than from_date
        if((File.join(path,start_file_name) <=> log_file ) <=0)
          CSV.foreach(log_file, :headers => true) do |csv_obj|
            if(!csv_obj.empty?)
              logs_time = Date.parse(csv_obj[0])
              if(!from_date.nil?)
                if( logs_time >= from_date)
                  list_logs << csv_obj.to_hash
                end
              else
                list_logs << csv_obj.to_hash
              end
              persist_from_date = csv_obj[0]
              persist_start_file_name = File.basename(log_file)
            end
          end
        end
      end
    else
      #File sorted DESC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.last
      end
      Dir.glob(path+"/*.csv").sort.reverse.each do |log_file|
        #Retrieve data from csv file and only get logs line if the logs time is equal or earlier than from_date
        if((File.join(path,start_file_name) <=> log_file ) >= 0)
          CSV.foreach(log_file, :headers => true) do |csv_obj|
            if(!csv_obj.empty?)
              logs_time = Date.parse(csv_obj[0])
              if(!from_date.nil?)
                if(logs_time <= from_date)
                  list_logs << csv_obj.to_hash
                end
              else
                list_logs << csv_obj.to_hash
              end
              persist_from_date = csv_obj[0]
              persist_start_file_name = File.basename(log_file)
            end
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
  persist_data["from_date"] = persist_from_date
  finalData["persistent_data"] = persist_data
  return finalData
end