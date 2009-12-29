require "log4r/outputter/fileoutputter"
require "log4r/staticlogger"

module Log4r

  # RollingFileOutputter - subclass of FileOutputter that rolls files on size
  # or time. Additional hash arguments are:
  #
  # [<tt>:maxsize</tt>]   Maximum size of the file in bytes.
  # [<tt>:trunc</tt>]	  Maximum age of the file in seconds.
  # [<tt>:keep</tt>]      the number of rolled logfiles to keep 
  #                       if keep == 3, then there will be files 
  #                       [blah.log, blah.log.0, blah.log.1, blah.log.2]
  #                       
  class UnixRollingFileOutputter < FileOutputter

    attr_reader :keep, :maxsize, :maxtime, :start_time#,i:base_filename

    def initialize(_name, hash={})
      @keep = 0
      super(_name, hash)
      if hash.has_key?(:maxsize) || hash.has_key?('maxsize') 
        _maxsize = (hash[:maxsize] or hash['maxsize']).to_i
        if _maxsize.class != Fixnum
          raise TypeError, "Argument 'maxsize' must be an Fixnum", caller
        end
        if _maxsize == 0
          raise TypeError, "Argument 'maxsize' must be > 0", caller
        end
        @maxsize = _maxsize
      end
      if hash.has_key?(:maxtime) || hash.has_key?('maxtime') 
        _maxtime = (hash[:maxtime] or hash['maxtime']).to_i
        if _maxtime.class != Fixnum
          raise TypeError, "Argument 'maxtime' must be an Fixnum", caller
        end
        if _maxtime == 0
          raise TypeError, "Argument 'maxtime' must be > 0", caller
        end
        @maxtime = _maxtime
        @start_time = Time.now
      end

      if hash.has_key?(:keep) || hash.has_key?('keep') 
        keep = (hash[:keep] or hash['keep']).to_i
        if keep <= 0
          raise StandardError, "Argument 'keep' must be >= 1, not #{keep.inspect}"
        end

        @keep = keep
      else
        raise StandardError, "You must provide a non-zero 'keep' argument"
      end

      # initialize the file size counter
      @datasize = File.size(@filename)
    end

    #######
    private
    #######

    # perform the write
    def write(data) 
      # we have to keep track of the file size ourselves - File.size doesn't
      # seem to report the correct size when the size changes rapidly
      @datasize += data.size + 1 # the 1 is for newline
      super
      roll if roll_required?
    end

    # does the file require a roll?
    def roll_required?
      if !@maxsize.nil? && @datasize > @maxsize
        @datasize = 0
        return true
      end
      if !@maxtime.nil? && (Time.now - @start_time) > @maxtime
        @start_time = Time.now
        return true
      end
      false
    end 

    # roll the file
    def roll
      begin
        @out.fsync
        @out.close
      rescue 
        Logger.log_internal {
          "RollingFileOutputter '#{@name}' could not close #{@filename}"
        }
      end

      (@keep - 2).downto(0) do |i|
        a, b = "#{filename}.#{i}", "#{filename}.#{i+1}"
        FileUtils.mv(a,b) if File.exist?(a)
      end

      FileUtils.mv(filename, "#{filename}.0")
      @out = open_logfile
    end 
  end
end


