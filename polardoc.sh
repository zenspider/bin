#!/bin/sh
#
if [ -z ${CLASSPATH:=""} ] ; then
#   Edit and uncomment line below. eg. CLASSPATH=/usr/jdk/lib/polardoc1.0.4.jar
	CLASSPATH=/mom4/users/ryand/JavaSource/polardoc1.0.4.jar
else
#   Edit and uncomment line below
	CLASSPATH=$CLASSPATH:/mom4/users/ryand/JavaSource/polardoc1.0.4.jar
fi
export CLASSPATH
exec java -mx196m polardoc.Main "$@"
