# :nodoc:
# Version:: $Id: fileoutputter.rb,v 1.1.1.1 2004/03/19 03:31:09 fando Exp $

require "log4r/outputter/iooutputter"
require "log4r/staticlogger"

module Log4r

  # Convenience wrapper for File. Additional hash arguments are:
  #
  # [<tt>:filename</tt>]   Name of the file to log to.
  # [<tt>:trunc</tt>]      Truncate the file?
  # [<tt>:sync</tt>]       synchronize writes to the filesystem?
  class FileOutputter < IOOutputter
    attr_reader :trunc, :filename, :sync

    def initialize(_name, hash={})
      super(_name, nil, hash)

      @trunc = Log4rTools.decode_bool(hash, :trunc, true)
      @sync  = Log4rTools.decode_bool(hash, :sync, true)

      unless _filename = (hash[:filename] or hash['filename'])
        raise StandardError, "you must supply a 'filename' argument"
      end

      _filename = _filename.to_s

      # file validation
      if FileTest.exist?( _filename )
        if not FileTest.file?( _filename )
          raise StandardError, "'#{_filename}' is not a regular file", caller
        elsif not FileTest.writable?( _filename )
          raise StandardError, "'#{_filename}' is not writable!", caller
        end
      else # ensure directory is writable
        dir = File.dirname( _filename )
        if not FileTest.writable?( dir )
          raise StandardError, "'#{dir}' is not writable!"
        end
      end

      @filename = _filename
      @out = open_logfile

      Logger.log_internal {
        "FileOutputter '#{@name}' writing to #{@filename}"
      }
    end

    protected
    
    def open_logfile
      fp = File.new(@filename, (@trunc ? "w" : "a")) 
      fp.sync = @sync
      fp
    end
  end
  
end
