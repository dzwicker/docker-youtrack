#!/bin/bash -eu

if "x${YOUTRACK_BASE_URL}" != "x"; then
	exec java \
		-XX:MaxMetaspaceSize=250m -Xmx1g \
		-Duser.home=/var/lib/youtrack \
		-Djava.security.egd=/dev/zrandom \
		-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit \
		-Djetbrains.youtrack.disableBrowser=true -Djetbrains.youtrack.enableGuest=false \
		-Djetbrains.mps.webr.log4jPath=/etc/youtrack/log4j.xml -Djava.awt.headless=true \
		-Djetbrains.youtrack.baseUrl=${YOUTRACK_BASE_URL}
		-jar /usr/local/youtrack/youtrack.jar 8080
else
	exec java \
		-XX:MaxMetaspaceSize=250m -Xmx1g \
		-Duser.home=/var/lib/youtrack \
		-Djava.security.egd=/dev/zrandom \
		-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit \
		-Djetbrains.youtrack.disableBrowser=true -Djetbrains.youtrack.enableGuest=false \
		-Djetbrains.mps.webr.log4jPath=/etc/youtrack/log4j.xml -Djava.awt.headless=true \
		-jar /usr/local/youtrack/youtrack.jar 8080
fi
