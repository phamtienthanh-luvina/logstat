##
# get logs from socket
# @param host
# @param port
# @param timeout
# @return listLogs
##
def getDataFromSocket(port,timeout,host)

  if(timeout.is_a? String)
    timeout = timeout.to_i
  end
  if(port.is_a? String)
    port = timeout.to_i
  end
  require 'socket'
  require 'timeout'
  begin
    server = TCPServer.open(host,port)  # Socket to listen on @port
    listLogs = Array.new
    start_time = Time.now
    end_time = start_time
    #Check if process not timeout
    while(end_time - start_time < timeout ) do
      begin
        Timeout.timeout(timeout) do
          Thread.start(server.accept) do |socket|
            begin
              logs_string = socket.gets
              listLogs << logs_string
            rescue Exception => e
              puts "[Logstat]  :  #{e}"
            ensure
              socket.close
            end
          end
          end_time = Time.now
        end
      rescue Timeout::Error
        puts "[Logstat] : Timeout error !"
      end
    end
  rescue Exception => ex
    puts "[Logstat]  :  #{ex}"
  end
  finalData = Hash.new
  finalData["list_logs"] = listLogs
  return finalData
end
