#!/bin/bash
set -e

TOMCAT_VERSION="9.0.85"
TOMCAT_HOME="/opt/tomcat"
TOMCAT_PORT="8070"
WAR_SRC="/tmp/simplej2ee.war"

echo ">>> Installing Java 11..."
apt-get update -qq
apt-get install -y -qq openjdk-11-jdk

echo ">>> Creating tomcat user..."
groupadd -f tomcat
id -u tomcat &>/dev/null || useradd -r -g tomcat -d "$TOMCAT_HOME" -s /bin/false tomcat

echo ">>> Installing Tomcat $TOMCAT_VERSION..."
mkdir -p "$TOMCAT_HOME"
if [ ! -f "$TOMCAT_HOME/bin/startup.sh" ]; then
    wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -O /tmp/tomcat.tar.gz
    tar -xzf /tmp/tomcat.tar.gz -C "$TOMCAT_HOME" --strip-components=1
    rm /tmp/tomcat.tar.gz
fi

echo ">>> Configuring port $TOMCAT_PORT..."
sed -i 's/port="8080"/port="'"$TOMCAT_PORT"'"/' "$TOMCAT_HOME/conf/server.xml"

echo ">>> Deploying WAR..."
cp "$WAR_SRC" "$TOMCAT_HOME/webapps/simplej2ee.war"
chown -R tomcat:tomcat "$TOMCAT_HOME"

echo ">>> Creating systemd service..."
cat > /etc/systemd/system/tomcat.service << 'EOF'
[Unit]
Description=Apache Tomcat 9
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable tomcat
systemctl restart tomcat

echo ">>> Waiting for Tomcat on port $TOMCAT_PORT..."
for i in $(seq 1 12); do
    nc -z localhost "$TOMCAT_PORT" 2>/dev/null && echo ">>> Tomcat is up!" && exit 0
    sleep 5
done
echo ">>> WARNING: Tomcat did not respond on port $TOMCAT_PORT after 60s"
