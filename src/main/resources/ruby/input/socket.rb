
##
# get logs from socket
# @param host
# @param port
# @param timeout
# @return listLogs
##
def getDataFromSocket(port,timeout,host)
  require 'socket'
  begin
    server = TCPServer.open(host,port)  # Socket to listen on @port
    listLogs = Array.new
    start_time = Time.now
    end_time = start_time
    #Check if process not timeout
    while(end_time - start_time < timeout ) do
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
  rescue Exception => ex
      puts "[Logstat]  :  #{ex}"
  end
  return listLogs
end
