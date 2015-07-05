#!/bin/sh

# -----------------------------------------------------------------------------
# Control Script for the Game Server
#
# Environment Variable Prerequisites
#
#   Do not set the variables in this script. Instead put them into a script
#   setenv.sh in bin folder to keep your customizations separate.
#
#   JAVA_HOME      		Must point at your Java Development Kit installation.
#
#   APP_NAME  			Application Name without space.
#
#	APP_MAIN_CLASS		Application EntryPoint
#
#	APP_CLASSPATH		Application Classpath
#
#   APP_OUT    			(Optional) Full path to a file where stdout and stderr
#                   	will be redirected.
#                  		Default is $APP_HOME/logs/gameserver.out
#
#
#   JAVA_OPTS       	(Optional) Java runtime options used when any command
#                   	is executed.
#                   	
#   APP_PID 			(Optional) Path of the file which should contains the pid of the app startup java process, when start (fork) is used
#
#
# -----------------------------------------------------------------------------
 
 
# OS specific support.  $var _must_ be set to either true or false.
cygwin=false
case "`uname`" in
CYGWIN*) cygwin=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

# Only set APP_HOME if not already set
[ -z "$APP_HOME" ] && APP_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`

cd "$APP_HOME";


# Ensure that any user defined APP_CLASSPATH variables are not used on startup,
# but allow them to be specified in setenv.sh, in rare case when it is needed.
APP_CLASSPATH=

if [ -r "$APP_HOME/bin/setenv.sh" ]; then
  . "$APP_HOME/bin/setenv.sh"
fi
 

# For Cygwin, ensure paths are in UNIX format before anything is touched
if $cygwin; then
  echo CYGWIN env detected : converting path
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
  [ -n "$APP_HOME" ] && APP_HOME=`cygpath --unix "$APP_HOME"`
  [ -n "$APP_CLASSPATH" ] && APP_CLASSPATH=`cygpath --path --unix "$APP_CLASSPATH"`
fi


if [ -z "$APP_PID" ] ; then
  APP_PID="$APP_HOME"/bin/$APP_NAME.pid
fi

if [ -z "$APP_OUT" ] ; then
  APP_OUT="$APP_HOME"/bin/$APP_NAME.out
fi


# For Cygwin, switch paths to Windows format before running java
if $cygwin; then
  JAVA_HOME=`cygpath --absolute --windows "$JAVA_HOME"`
  APP_HOME=`cygpath --absolute --windows "$APP_HOME"`
  APP_CLASSPATH=`cygpath --path --windows "$APP_CLASSPATH"`
fi


  echo "Using APP_NAME:   $APP_NAME"
  echo "Using APP_HOME:   $APP_HOME"
  echo "Using JAVA_HOME:       $JAVA_HOME"
  echo "Using APP_CLASSPATH:       $APP_CLASSPATH"
  if [ ! -z "$APP_PID" ]; then
    echo "Using APP_PID:    $APP_PID"
  fi
 
 
 
# Makes the file $1 writable by the group $serviceGroup.
function makeFileWritable {
   local filename="$1"
   touch $filename || return 1
   chmod g+w $filename || return 1
   return 0; }
 
# Returns 0 if the process with PID $1 is running.
function checkProcessIsRunning {
	local pid="$1"
	if [ -z "$pid" -o "$pid" == " " ]
	then 
		return 1
	fi
	
	if [ -e /proc ]
	then   
		if [ ! -e /proc/$pid ]
		then 
			return 1
		fi		
	else
		number=$(ps aux | grep $APP_NAME | wc -l)
		if [ $number -gt 1 ]
		then
			return 0;
		else
			return 1;
		fi
	fi
	echo " return 0"
	return 0; 
}
 
# Returns 0 when the service is running and sets the variable $pid to the PID.
function getServicePID {
   if [ ! -f $APP_PID ]; then return 1; fi
   pid="$(<$APP_PID)"
   checkProcessIsRunning $pid || return 1
   #checkProcessIsOurService $pid || return 1
   return 0; }
 
function startServiceProcess {
   cd $APP_HOME || return 1
   rm -f $APP_PID
   makeFileWritable $APP_PID || return 1
   makeFileWritable $APP_OUT || return 1
   
   cmd=" \"$JAVA_HOME/bin/java\" $JAVA_OPTS $APP_OPTS -classpath \"$APP_CLASSPATH\" \"$APP_MAIN_CLASS\"	>> $APP_OUT 2>&1 & echo \$! > $APP_PID"
	
   eval $cmd ||return 1;   
   
   #$SHELL -c "$cmd" || return 1
   sleep 1
   pid="$(<$APP_PID)"
   if checkProcessIsRunning $pid; then :; else
      echo -ne "\n$APP_NAME start failed, see logfile."
      return 1
   fi
   return 0; }
   
 
function stopServiceProcess {
   kill $pid || return 1
   for ((i=0; i<maxShutdownTime*10; i++)); do
      checkProcessIsRunning $pid
      if [ $? -ne 0 ]; then
         rm -f $APP_PID
         return 0
         fi
      sleep 0.1
      done
   echo -e "\n$APP_NAME did not terminate within $maxShutdownTime seconds, sending SIGKILL..."
   kill -s KILL $pid || return 1
   local killWaitTime=15
   for ((i=0; i<killWaitTime*10; i++)); do
      checkProcessIsRunning $pid
      if [ $? -ne 0 ]; then
         rm -f $APP_PID
         return 0
         fi
      sleep 0.1
      done
   echo "Error: $APP_NAME could not be stopped within $maxShutdownTime+$killWaitTime seconds!"
   return 1; }
 
function startService {
   getServicePID
   if [ $? -eq 0 ]; then echo -n "$APP_NAME is already running"; RETVAL=0; return 0; fi
   echo -n "Starting $APP_NAME   "
   startServiceProcess
   if [ $? -ne 0 ]; then RETVAL=1; echo "failed"; return 1; fi
   echo "started PID=$pid"
   RETVAL=0
   return 0; }
   
function stopService {
   getServicePID
   if [ $? -ne 0 ]; then echo -n "$APP_NAME is not running"; RETVAL=0; echo ""; return 0; fi
   echo -n "Stopping $APP_NAME   "
   stopServiceProcess
   if [ $? -ne 0 ]; then RETVAL=1; echo "failed"; return 1; fi
   echo "stopped PID=$pid"
   RETVAL=0
   return 0; }
 
function checkServiceStatus {
   echo -n "Checking for $APP_NAME:   "
   if getServicePID; then
    echo "running PID=$pid"
    RETVAL=0
   else
    echo "stopped"
    RETVAL=3
   fi
   return 0; }
 
function main {
   RETVAL=0
   case "$1" in
      start)                                               # starts the Java program as a Linux service
         startService
         ;;
      stop)                                                # stops the Java program service
         stopService
         ;;
      restart)                                             # stops and restarts the service
         stopService && startService
         ;;
      status)                                              # displays the service status
         checkServiceStatus
         ;;
      *)
         echo "Usage: $0 {start|stop|restart|status}"
         exit 1
         ;;
      esac
   exit $RETVAL
}
 
main $1