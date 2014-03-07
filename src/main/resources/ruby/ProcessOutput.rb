require 'ruby/libs/Common.rb'

include CommonUtils

class ProcessOutput
  ##
  # output: process output
  # @param data: data receive after process filter
  # @param output_conf: output configuration from job
  # @param map_default_output: default information for output
  ##
  def output(data, output_conf, map_default_output)
    if(!data.nil?)
      if(!data["list_logs"].nil? && !data["list_logs"].empty?)
        # Get output type
        outputType = "file"
        if output_conf['type'] != nil && output_conf['type'] != ''
          outputType = output_conf['type']
        end
        # Check outputType to call corresponding process
        if outputType == "file" # Out to file/stdout
          configFile = output_conf['config']
          if(!configFile.nil? && !configFile.empty?)
            if configFile['path'] != nil && configFile['path'] != '' && configFile['path'] != "stdout"
              self.writeToFile(data['list_logs'], configFile['path'])
            else
              data['list_logs'].each do |eLog|
                puts "#{eLog}"
              end
            end
          else
            puts "[Logstat]: No output configuration specific !"
          end
        elsif outputType == "mongoDB" # Put on MongoDB
          # Call method process insert to mongo db

          self.insertToMongo(data['list_logs'], output_conf['config'], map_default_output)
        elsif outputType == "http" # Out to servlet
          # Call method process send data to servlet
          self.sendToServlet(data['list_logs'], output_conf['config'], map_default_output)
        elsif outputType == "job" # Out to output job format
          # Call method process put out format of job's output
	  dataFromOutput = self.putOutJobFormat(data)
        end
      else
        puts "[Logstat]: No data to output !"
      end
    else
      puts "[Logstat]: No data to output !"
    end
    return dataFromOutput
  end

  ##
  # writeToFile: write data to file
  # @param input: output data to write
  # @param destination: file path
  ##
  def writeToFile(input, destination)
    begin
      File.open(destination, 'w') do |file|
        input.each do |line|
          file.puts(line)
        end
      end
    rescue Exception => e
      puts "[Logstat]: Can not create/open file with path config !!!"
    end
  end

  ##
  # insertToMongo: insert data to mongo db
  # @param data: output data to insert
  # @param mongoConf: configuration from job
  ##
  def insertToMongo(data, mongoConf, mapDefaultOutput)
    CommonUtils.require_gem('bson')
    CommonUtils.require_gem('mongo')
    CommonUtils.require_gem('bson_ext')
    include Mongo

    if mongoConf != {}
      # Host
      host = mapDefaultOutput['host']
      if mongoConf['host'] != nil && mongoConf['host'] != ''
        host = mongoConf['host']
      end
      # Port
      port = mapDefaultOutput['port']
      if mongoConf['port'] != nil && mongoConf['port'] != ''
        port = mongoConf['port']
      end
      # Database name
      dbName = mapDefaultOutput['dbName']
      if mongoConf['dbName'] != nil && mongoConf['dbName'] != ''
        dbName = mongoConf['dbName']
      end
      # Table insert
      tblInsert = mapDefaultOutput['tblInsert']
      if mongoConf['tblName'] != nil && mongoConf['tblName'] != ''
        tblInsert = mongoConf['tblName']
      end
      # User, Password
      user = mongoConf['user']
      pass = mongoConf['pass']

      # Process write data to mongodb
      begin
        # Get db connections
        db = MongoClient.new(host, port).db(dbName)
        db.authenticate(user, pass)
        tbl_log = db.collection(tblInsert)
        tbl_log.insert(data)
        puts "[Logstat]: SUCCESS: Write data to MongoDB (table: #{tblInsert})!!!"
      rescue Exception => ex
        puts "[Logstat]: ERROR: #{ex}"
      end
    else
      puts "[Logstat]: Must be config information (host, port, dbName, user, pass) to put data to MongoDB !!!"
    end
  end

  ##
  # sendToServlet: send data to servlet
  # @param data: output data to send
  # @param servletConf: configuration from job
  ##
  def sendToServlet(data, servletConf, mapDefaultOutput)
    CommonUtils.require_gem('uri')
    CommonUtils.require_gem('net/http')
    #CommonUtils.require_gem('active_support')
    CommonUtils.require_gem('json')

    pathConf = mapDefaultOutput['pathConf']
    if servletConf['path'] != nil && servletConf['path'] != ''
      pathConf = servletConf['path']
      if !pathConf.include? "http"
        pathConf = "http://#{pathConf}"
      end
    end
    uri = URI.parse(pathConf)
    @host = uri.host
    @port = uri.port
    @path = uri.path

    @body = JSON(data)

    request = Net::HTTP::Post.new(@path, initheader = {'Content-Type' =>'application/json'})
    request.body = @body
    response = Net::HTTP.new(@host, @port).start {|http| http.request(request) }
  end

  ##
  # putOutJobFormat:
  # @param data: output data to send
  # @param jobConf: configuration from job
  # @return data
  ##
  def putOutJobFormat(data)
    CommonUtils.require_gem('rubygems')
    CommonUtils.require_gem('json')
    data = JSON(data)
    return data
  end
end