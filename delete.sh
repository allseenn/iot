#!/bin/bash
docker rm $(docker ps | grep node-red | awk '{ print $1}') -f
docker rm $(docker ps | grep wireguard | awk '{ print $1}') -f
docker rm $(docker ps | grep eclipse-mosquitto | awk '{ print $1}') -f
docker rm $(docker ps | grep telegraf | awk '{ print $1}') -f
docker rmi $(docker images | grep eclipse-mosquitto | awk '{ print $3}')
docker rmi $(docker images | grep wireguard | awk '{ print $3}')
docker rmi $(docker images | grep influxdb | awk '{ print $3}')
docker rm $(docker ps | grep influxdb | awk '{ print $1}') -f
docker rmi $(docker images | grep influxdb | awk '{ print $3}')
docker rmi $(docker images | grep node-red | awk '{ print $3}')
docker rm $(docker ps -a | grep grafana-oss | awk '{ print $1}') -f
docker rmi $(docker images | grep grafana | awk '{ print $3}')
rm -rf ~/grafana
rm -rf ~/influxdb2
rm -rf ~/mosquitto
rm -rf ~/node-red
rm -rf ~/telegraf
rm -rf ~/wireguard
rm ~/docker-compose.yml
docker network prune

