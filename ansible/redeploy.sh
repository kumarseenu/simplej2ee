#!/bin/bash
set -e

TOMCAT_HOME="/opt/tomcat"
WAR_SRC="/tmp/simplej2ee.war"

echo ">>> Stopping Tomcat..."
systemctl stop tomcat

echo ">>> Removing old deployment..."
rm -rf "$TOMCAT_HOME/webapps/simplej2ee.war" "$TOMCAT_HOME/webapps/simplej2ee"

echo ">>> Deploying new WAR..."
cp "$WAR_SRC" "$TOMCAT_HOME/webapps/simplej2ee.war"
chown tomcat:tomcat "$TOMCAT_HOME/webapps/simplej2ee.war"

echo ">>> Starting Tomcat..."
systemctl start tomcat

echo ">>> Waiting for Tomcat on port 8070..."
for i in $(seq 1 12); do
    nc -z localhost 8070 2>/dev/null && echo ">>> Tomcat is up!" && exit 0
    sleep 5
done
echo ">>> WARNING: Tomcat did not respond after 60s"
