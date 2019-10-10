#!/bin/bash

current_path=`pwd`
case "`uname`" in
    Linux)
		bin_abs_path=$(readlink -f $(dirname $0))
		;;
	*)
		bin_abs_path=`cd $(dirname $0); pwd`
		;;
esac
base=${bin_abs_path}/..
otter_conf=$base/conf/otter.properties
logback_configurationFile=$base/conf/logback.xml

export LANG=en_US.UTF-8
export BASE=$base

if [ ! -d $base/logs ] ; then 
	mkdir -p $base/logs
fi

## set java opts

JAVA_OPTS="-server -Xms2048m -Xmx3072m -Xmn1024m -XX:SurvivorRatio=2 -XX:PermSize=96m -XX:MaxPermSize=256m -Xss256k -XX:-UseAdaptiveSizePolicy -XX:MaxTenuringThreshold=15 -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryError"

JAVA_OPTS=" $JAVA_OPTS -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8"
OTTER_OPTS="-DappName=otter-manager -Ddubbo.application.logger=slf4j -Dlogback.configurationFile=$logback_configurationFile -Dotter.conf=$otter_conf"

if [ -e $otter_conf -a -e $logback_configurationFile ]
then 
	
	for i in $base/lib/*;
		do CLASSPATH=$i:"$CLASSPATH";
	done
 	CLASSPATH="$base:$base/conf:$CLASSPATH";
 	
 	echo "cd to $bin_abs_path for workaround relative path"
  	cd $bin_abs_path
 	
	echo LOG CONFIGURATION : $logback_configurationFile
	echo otter conf : $otter_conf 
	echo CLASSPATH :$CLASSPATH
	java $JAVA_OPTS $JAVA_DEBUG_OPT $OTTER_OPTS -classpath .:$CLASSPATH com.alibaba.otter.manager.deployer.OtterManagerLauncher 1>>$base/logs/manager.log 2>&1
else 
	echo "otter conf("$otter_conf") OR log configration file($logback_configurationFile) is not exist,please create then first!"
fi
