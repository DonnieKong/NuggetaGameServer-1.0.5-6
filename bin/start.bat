@echo off

TITLE NuggetaGameServer

SET JAVA_OPTS=-server -Xms128m -Xmx256m

SET APP_HOME=..
SET APP_NAME="NuggetaGameServer"
SET APP_MAIN_CLASS="com.nuggeta.gameserver.GameServer"
SET APP_CLASSPATH=.;conf;war;lib\*;ext\*

cd %APP_HOME%

"java" %JAVA_OPTS% -classpath %APP_CLASSPATH% %APP_MAIN_CLASS%


pause