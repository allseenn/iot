#!/bin/bash
PUB_IP=$(wget -qO- ifconfig.me)
mkdir -m 777 -p ~/mosquitto/config && \
mkdir -m 777 -p ~/mosquitto/data && \
mkdir -m 777 -p ~/mosquitto/log && \
mkdir -m 777 -p ~/influxdb2/data && \
mkdir -m 777 -p ~/influxdb2/conf && \
mkdir -m 777 -p ~/telegraf/conf && \
mkdir -m 777 -p ~/grafana/data && \
mkdir -m 777 -p ~/grafana/conf && \
mkdir -m 777 -p ~/grafana/log && \
mkdir -m 777 -p ~/node-red/data && \
mkdir -m 777 -p ~/wireguard/config

cat > ~/mosquitto/config/mosquitto.conf <<EOF
listener 1883
allow_anonymous false
password_file /mosquitto/config/password.txt
EOF

cat > ~/mosquitto/config/password.txt <<EOF
IoT:$7$101$aCqLHE29HaTi3vZ0$+w/o+7nS64+P3MbNIRawiNUHBX/+4Uz4W1t5Fu44C0irXfK5HynzD58DOU0ASdCPb50r8+9yr8R1F9h9YTupzA==
EOF

cat > ~/node-red/data/settings.js <<EOF
module.exports = {
    flowFile: 'flows.json',
    flowFilePretty: true,
    adminAuth: {
    	type: "credentials",
    	users: [{
    		username: "admin",
    		password: "$2b$08$XFZjnp5xlVjiiMJPftF0WOoJuo.DbvFq1E8CnoIRdC.kOr.PQnoK6",
    		}]
    	},
    uiPort: process.env.PORT || 1880,
    diagnostics: {
        enabled: true,
        ui: true,
    },
    runtimeState: {
        enabled: false,
        ui: false,
    },
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },
    exportGlobalContextKeys: false,
    externalModules: {
    },
    editorTheme: {
        palette: {
        },
        projects: {
            enabled: false,
            workflow: {
                mode: "manual"
            }
        },
        codeEditor: {
            lib: "monaco",
            options: {
            }
        },
        markdownEditor: {
            mermaid: {
                enabled: true
            }
        },
    },
    functionExternalModules: true,
    functionTimeout: 0,
    functionGlobalContext: {
    },
    debugMaxLength: 1000,
    mqttReconnectTime: 15000,
    serialReconnectTime: 15000,
}
EOF

cat > ~/influxdb2/conf/config.yml <<EOF
influxdb:
  reporting-disabled: false
  bind-address: ":8086"
  log-level: info

  auth:
    admin:
      username: admin
      password: students
      token: MbHT00nM2ucQNEwInmu8uWI7r-MGtnYyspyXrI0AF1FmjaTaq8bF3ZPSjS82utVx-NnxGsi19Upk__QSlX5TBA==
EOF

cat > ~/telegraf/conf/telegraf.conf <<EOF
[agent]
interval = "3s"
round_interval = true
metric_batch_size = 1000
metric_buffer_limit = 10000
collection_jitter = "0s"
flush_interval = "3s"
flush_jitter = "0s"
precision = ""
hostname = ""
omit_hostname = false
[[outputs.influxdb_v2]]
urls = ["http://$PUB_IP:8086"]
token = "!copy_token_here!"
organization = "IoT"
bucket = "IoT"
[[inputs.mqtt_consumer]]
servers = ["tcp://$PUB_IP:1883"]
topics = ["#"]
username = "IoT"
password = "students"
data_format = "value"
data_type = "float"
EOF

cat > docker-compose.yml <<EOF
version: "2"
services:
  influxdb:
    container_name: influxdb
    image: influxdb:latest
    environment:
      - TZ=Europe/Moscow
    ports:
      - "8086:8086"
    volumes:
      - ~/influxdb2/data:/var/lib/influxdb2
      - ~/influxdb2/conf:/etc/influxdb2/
    networks:
      - influxdb-net
    restart: always
  wireguard:
    container_name: wireguard
    image: lscr.io/linuxserver/wireguard:latest
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
      - SERVERURL=$PUB_IP
      - SERVERPORT=1871 #optional
      - PEERS=5 #optional
      - PEERDNS=1.1.1.1 #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
      - ALLOWEDIPS=0.0.0.0/0 #optional
      - LOG_CONFS=false #optional
    volumes:
      - ~/wireguard/config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: always
  telegraf:
    container_name: telegraf
    image: telegraf:latest
    environment:
      - TZ=Europe/Moscow
    volumes:
      - ~/telegraf/conf/:/etc/telegraf/
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - telegraf-net
    restart: always
  grafana:
    container_name: grafana
    image: grafana/grafana-oss:latest
    environment:
      - TZ=Europe/Moscow
    ports:
      - "80:3000"
    volumes:
      - ~/grafana/data:/var/lib/grafana
      - ~/grafana/log:/var/log/grafana
      - ~/grafana/conf/:/etc/grafana/
    links:
      - influxdb
    networks:
      - grafana-net
    restart: always
  mosquitto:
    container_name: mosquitto
    image: eclipse-mosquitto:latest
    environment:
      - TZ=Europe/Moscow
    volumes:
      - ~/mosquitto/:/mosquitto
    ports:
      - 1883:1883
    networks:
      - mosquitto-net
    restart: always
  node-red:
    container_name: node-red
    image: nodered/node-red:latest
    environment:
      - TZ=Europe/Moscow
    ports:
      - "1880:1880"
    volumes:
      - ~/node-red/data:/data
    networks:
      - node-red-net
    restart: always
networks:
  node-red-net:
  influxdb-net:
  mosquitto-net:
  grafana-net:
  telegraf-net:
EOF

docker compose up -d

