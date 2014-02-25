module CommonUtils
  def require_gem(gem,pack=nil)
    begin
      require gem
    rescue LoadError => e
      require 'fileutils'
      dirname = get_jar_path + "/gemdir"
      find = false
      Dir.glob(dirname + "/gems/" + gem + "*/").each {|subdir|
        gemlibsdir = subdir + "/lib"
        $LOAD_PATH.unshift(gemlibsdir) unless $LOAD_PATH.include?(gemlibsdir)
        find = true
      }

      if( not find)
        require 'timeout'
        puts("#{pack||gem} not found ! Install gem....")
        puts("Maybe you have to input enter after #{pack||gem} gem is installed to back main process...")
        FileUtils.mkdir_p(dirname)
        gem_install_cmd = "gem install -i #{dirname} #{pack||gem} --no-ri --no-rdoc"
        system(gem_install_cmd)
        Dir.glob(dirname + "/gems/" + gem + "*/").each {|subdir|
          gemlibsdir = subdir + "/lib"
          $LOAD_PATH.unshift(gemlibsdir) unless $LOAD_PATH.include?(gemlibsdir)
        }
      end
      require gem
    end
  end

  def get_jar_path
    scriptpath = __FILE__[/(jar\:file\:)(.*)\/.+\.jar!/]
    $2
  end
end
