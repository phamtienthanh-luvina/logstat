require 'ruby/ProcessInput'
require 'date'

##
# ProcessFilter: process raw log data
##
class ProcessFilter
  ##
  # filter: process raw log data
  # @param filter_type: match_field | match_log_record
  # @param filter_conf: map config from job
  # @param list_logs: list data from process input
  # @return resultData: list log data after process filter
  ##
  def filter(filter_type, filter_conf, mapDataFromInput)
    resultData = Array.new
    finalData = Hash.new
    if(!mapDataFromInput.nil?)
      list_logs = mapDataFromInput['list_logs']
      if list_logs != nil && list_logs != []
        if list_logs[0].class.to_s == "String"
          resultData = filterListString(filter_type, filter_conf, list_logs)
        elsif list_logs[0].class.to_s == "Hash"
          resultData = filterListMap(filter_conf, list_logs)
        end
      end
      finalData['list_logs'] = resultData
      finalData['persistent_data'] = mapDataFromInput['persistent_data']
    else
      puts "[Logstat]: No data for filter !"
      return
    end
    return finalData
  end

  ##
  # filterListString:
  # @param typeRegx: match_field | match_log_record
  # @param mapFilterConf: map config from job
  # @param listLogs: list data from process input
  # @return resultRegexp: list log data (format log: string)
  ##
  def filterListString(typeRegx, mapFilterConf, listLogs)
    resultRegexp = Array.new
    if typeRegx == "match_field"
      listLogs.each do |line|
        check = false
        tmpMapResult = Hash.new
        if !mapFilterConf.nil? && !mapFilterConf.empty?
          mapFilterConf.each do |key,value|
            strMatch = line.match(/#{value.strip}/).to_s
            if((!strMatch.nil?) && strMatch.strip != "")
              check = true
            end
            tmpMapResult[key.strip] = strMatch
          end
          if check == true
            resultRegexp << tmpMapResult
          end
        else
          puts "[Logstat]: Map filter configuration can not be empty !!!"
          return
        end
      end
    elsif typeRegx == "match_log_record"
      if (!mapFilterConf.nil? && !mapFilterConf.empty?)
        formatLog = mapFilterConf['format_log']
        mapDataFilter = mapFilterConf['data']
        if( !formatLog.nil? && formatLog != '' && !mapDataFilter.nil? && !mapDataFilter.empty?)
          listLogs.each do |log|
            mapTmpData = Hash.new
            listMatcher = log.match /#{formatLog}/
            if listMatcher != nil
              mapDataFilter.each { |key, value|
                mapTmpData[value] = listMatcher[key].strip
              }
              resultRegexp << mapTmpData
            end
          end
        else
          puts "[Logstat]: Format log and map data filter can not be empty !!!"
          return
        end
      end
    end
    return resultRegexp
  end

  ##
  # filterListMap: process with format input List<Map>
  # @param listLogs: log data input receive after process input
  # @param mapFilterConf: configuration of filter from job
  # @return result: list log data
  ##
  def filterListMap(mapFilterConf, listLogs)
    # Get data file
    list_data_field = Array.new
    if mapFilterConf['data_field'] != nil
      list_data_field = mapFilterConf['data_field']
    end
    # Get filter expression
    filter = Hash.new
    if mapFilterConf['filter'] != nil
      filter = mapFilterConf['filter']
    end
    # Process filter
    result = Array.new
    listFilterAppropriate = Array.new
    listLogs.each { |log|
      checkLogAppropriate = true
      filter.each { |field, regxCorresponding|
        dataFieldFilter = log[field].to_s.match(/#{regxCorresponding}/).to_s
        if dataFieldFilter.strip == '' || dataFieldFilter.nil?
          checkLogAppropriate = false
        end
      }
      if(checkLogAppropriate)
        listFilterAppropriate << log
      end
    }
    if listFilterAppropriate != []
      listFilterAppropriate.each { |log_filter|
        mapDataField = Hash.new
        if list_data_field != []
          list_data_field.each { |log_data_field|
            mapDataField[log_data_field] = log_filter[log_data_field]
          }
          result << mapDataField
        else
          result << log_filter
        end
      }
    else
      puts "[Logstat]: No record is appropriate with your filter !!!"
      return
    end
    return result
  end
end
