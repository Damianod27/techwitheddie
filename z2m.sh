#!/bin/bash
echo "----------------------------------------------------------------"
echo "Setting Up Your Hub W/ Zigbee2MQTT - Ver 1.0"
echo "----------------------------------------------------------------"
echo " "
# Z2M setup
echo ">>>>> Clone Zigbee2MQTT repository <<<<<"
sudo git clone https://github.com/Koenkk/zigbee2mqtt.git /opt/zigbee2mqtt
echo " "
echo ">>>>> Install dependencies <<<<<"
cd /opt/zigbee2mqtt
git checkout HEAD -- npm-shrinkwrap.json
git fetch
git checkout dev
git pull
npm ci
echo " "
echo ">>>>> Create configuration.yaml <<<<<"
cat > /opt/zigbee2mqtt/data/configuration.yaml <<EOL
# Home Assistant integration (MQTT discovery)
homeassistant: false

# allow new devices to join
permit_join: true

# MQTT settings
mqtt:
  # MQTT base topic for Zigbee2MQTT MQTT messages
  base_topic: zigbee2mqtt
  # MQTT server URL
  server: 'mqtt://localhost'
  # MQTT server authentication, uncomment if required:
  # user: my_user
  # password: my_password

# Serial settings
serial:
  # Location of the adapter (see first step of this guide)
  port: /dev/ttyAMA0

frontend:
  # Optional, default 8080 or you can use your own as well.
  port: 8082
  # IP address of the device running Zigbee2MQTT
  host: 192.168.86.12
advanced:
  log_level: debug
  network_key: GENERATE
EOL
echo " "
echo ">>>>> configuration.yaml file created <<<<<"
echo " "
echo ">>>>> Enable daemon with systemctl <<<<<"
cat > /etc/systemd/system/zigbee2mqtt.service <<EOL
[Unit]
Description=zigbee2mqtt
After=network.target

[Service]
ExecStart=/usr/bin/npm start
WorkingDirectory=/opt/zigbee2mqtt
StandardOutput=inherit
# Or use StandardOutput=null if you don't want Zigbee2MQTT messages filling syslog, for more options see systemd.exec(5)
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOL
echo " "
echo "Zigbee2MQTT Installed"
echo " "
echo ">>>>> Start Zigbee2MQTT automatically on boot <<<<<"
echo " "
sudo systemctl enable zigbee2mqtt.service
sudo reboot
