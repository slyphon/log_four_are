require 'syslog'
include Syslog::Constants

s1=Syslog.open( "test1", LOG_PID | LOG_CONS | LOG_PERROR, LOG_USER )
s1.log( LOG_INFO, "%s", "test1 test1" )

s2=Syslog.open( "test2", LOG_PID | LOG_CONS, LOG_USER )
s2.log( LOG_INFO, "%s", "test2 test2" )
