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
logback_configurationFile=$base/conf/logback.xml
export LANG=en_US.UTF-8

if [ ! -d $base/logs/node ] ; then 
	mkdir -p $base/logs/node
fi

if [ -z "$ARIA2C" ]; then
  ARIA2C=$(which aria2c)
fi

if [ -z "$ARIA2C" ]; then
	source $HOME/.bash_profile
	ARIA2C=$(which aria2c)
	
	if [ -z "$ARIA2C" ]; then
		echo "Cannot find a aria2c. Please set in your PATH in .bash_profile." 2>&2
		#exit 1;
	fi
fi

## set java opts

JAVA_OPTS="-server -Xms2048m -Xmx3072m -Xmn1024m -XX:SurvivorRatio=2 -XX:PermSize=96m -XX:MaxPermSize=256m -Xss256k -XX:-UseAdaptiveSizePolicy -XX:MaxTenuringThreshold=15 -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryError"

JAVA_OPTS=" $JAVA_OPTS -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8"
OTTER_OPTS="-DappName=otter-node -Ddubbo.application.logger=slf4j -Dlogback.configurationFile=$logback_configurationFile -Dnid=$1"

if [ -e $logback_configurationFile ]
then 
	for i in $base/lib/*;
	do CLASSPATH=$i:"$CLASSPATH";
	done
	CLASSPATH="$base/conf:$CLASSPATH";
 
	echo LOG CONFIGURATION : $logback_configurationFile
	echo CLASSPATH :$CLASSPATH

  echo "cd to $bin_abs_path for workaround relative path"
  cd $bin_abs_path

	java $JAVA_OPTS $JAVA_DEBUG_OPT $OTTER_OPTS -classpath .:$CLASSPATH com.alibaba.otter.node.deployer.OtterLauncher 1>>$base/logs/node/node.log 2>&1
else 
	echo "log configration file($logback_configurationFile) is not exist,please create then first!"
fi
