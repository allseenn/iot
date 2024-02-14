#!/bin/bash
cd
docker compose down
rm -rf ~/grafana
rm -rf ~/influxdb2
rm -rf ~/mosquitto
rm -rf ~/node-red
rm -rf ~/telegraf
rm -rf ~/wireguard
rm ~/docker-compose.yml


