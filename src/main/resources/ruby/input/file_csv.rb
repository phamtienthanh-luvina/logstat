#Get logs from csv file by line number
#@param : path - Path to logs directory
#@param : start_file_name - File logs will be start to read if no file specific,read oldest
#         or lastest file according to asc_by_fname
#@param : asc_by_fname - sort files in logs folder
#@return list_logs - a list of logs in hashes

def getLogsCSVByLine(path,start_file_name=nil,start_pos=nil,asc_by_fname=nil)
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

  #closure for read csv from file
  list_logs = Array.new
  require 'csv'
  if(asc_by_fname == nil)
    #Get logs from single file
    list_logs = Array.new
    if(start_file_name.nil?)
      puts "[Logstat] : Incorrect parameter : 'start_file_name' must be required if 'asc_by_fname' is obmitted "
      return
    end
    CSV.foreach(start_file_name, :headers => true) do |csv_obj|
      line_num = $.
      if(!csv_obj.empty? && line_num >= start_pos)
        list_logs << csv_obj.to_hash
      end
    end
  else
    #Get logs from multi files
  sorted_by_modified = Dir.glob(path).sort_by {|f| File.mtime(File.join(path,f))}.reject{|entry| entry == "." || entry == ".." || !(entry.end_with?(".csv")) }
    if(asc_by_fname)
      #File sorted  ASC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.first
      end
      Dir.glob(path+"/*.csv").sort.each  do |log_file|
        if((File.join(path,start_file_name) <=> log_file ) <=0)
          CSV.foreach(log_file, :headers => true) do |csv_obj|
            if(!csv_obj.empty?)
              if((File.join(path,start_file_name) <=> log_file) == 0)
                line_num = $.
                if(line_num >= start_pos)
                  list_logs << csv_obj.to_hash
                end
              else
                list_logs << csv_obj.to_hash
              end
            end
          end
        end
      end
    else
      #File sorted DESC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.last
      end
      Dir.glob(path + "/*.csv").sort.reverse.each do |log_file|
        if((File.join(path,start_file_name) <=> log_file ) >=0)
          CSV.foreach(log_file, :headers => true) do |csv_obj|
            if(!csv_obj.empty?)
              if((File.join(path,start_file_name) <=> log_file) == 0)
                line_num = $.
                if( line_num <= start_pos)
                  list_logs << csv_obj.to_hash
                end
              else
                list_logs << csv_obj.to_hash
              end
            end
          end
        end
      end
    end
  end
  return list_logs
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
  else
    from_date = Date.parse(Time.now.to_s)
  end
  #closure for read csv from file
  list_logs = Array.new
  require 'csv'
  if(asc_by_fname == nil)
    #Get logs from single file
    list_logs = Array.new
    CSV.foreach(File.join(path,start_file_name), :headers => true) do |csv_obj|
      #logs must start with a time
      if(!csv_obj.empty? )
        logs_time = Date.parse(csv_obj[0])
        if( logs_time >= from_date)
          list_logs << csv_obj.to_hash
        end
      end
    end
  else
    #Get logs from multi files
    sorted_by_modified = Dir.entries(path).sort_by {|f| File.mtime(File.join(path,f))}.reject{|entry| entry == "." || entry == ".." || !(entry.end_with?(".csv")) }
      puts sorted_by_modified
    if(asc_by_fname)
      #File sorted  ASC
      if(start_file_name == nil )
        start_file_name = sorted_by_modified.first
      end
      Dir.glob(path+"/*.csv").sort.each  do |log_file|
        if((File.join(path,start_file_name) <=> log_file ) >=0)
          puts log_file
          CSV.foreach(log_file, :headers => true) do |csv_obj|
            if(!csv_obj.empty?)
              logs_time = Date.parse(csv_obj[0])
              if(from_date != nil)
                puts logs_time >= from_date
                if( logs_time >= from_date)
                  list_logs << csv_obj.to_hash
                end
              else
                list_logs << csv_obj.to_hash
              end
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
        if((File.join(path,start_file_name) <=> log_file ) <= 0)
          CSV.foreach(csv_file, :headers => true) do |csv_obj|
            logs_time = Date.parse(csv_obj[0])
            if(!csv_obj.empty? && logs_time <= from_date)
              list_logs << csv_obj.to_hash
            end
          end
        end
      end
    end
  end
  return list_logs
end