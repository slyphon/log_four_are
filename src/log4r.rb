# :include: log4r/rdoc/log4r
#
# == Other Info
#
# Author::      Leon Torres
# Version::     $Id: log4r.rb,v 1.4 2009/09/25 20:33:47 colbygk Exp $

require "log4r/outputter/fileoutputter"
require "log4r/outputter/consoleoutputters"
require "log4r/outputter/staticoutputter"
require "log4r/outputter/rollingfileoutputter"
require "log4r/formatter/patternformatter"
require "log4r/loggerfactory"

module Log4r
  Log4rVersion = [1, 1, 2].join '.'
end
