#!/bin/sh

########################################
######### JAVA SERVER ##################
########################################
JAVA_OPTS="-server -Xms128m -Xmx256m"

########################################
######### APPLICATION NAME #############
########################################
APP_NAME="NuggetaGameServer"

########################################
######### APPLICATION MAIN CLASS #######
########################################
APP_MAIN_CLASS="com.nuggeta.gameserver.GameServer"

########################################
######### APPLICATION CLASSPATH #######
########################################
APP_CLASSPATH=$APP_HOME:$APP_HOME/conf:$APP_HOME/war:$APP_HOME/lib/*:$APP_HOME/ext/*




