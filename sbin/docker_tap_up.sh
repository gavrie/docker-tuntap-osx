#!/bin/bash

set -o nounset
set -o errexit

# Local and host tap interfaces
localTapInterface=tap1
hostTapInterface=eth1

# Local and host gateway addresses
localGateway='10.0.75.1/30'
hostGateway='10.0.75.2'
hostNetmask='255.255.255.252'

# Startup local and host tuntap interfaces
sudo ifconfig $localTapInterface $localGateway up
docker run --rm --privileged --net=host --pid=host alpine ifconfig $hostTapInterface $hostGateway netmask $hostNetmask up

# Route all docker networks through tap interface
networks=$(docker network  ls -f 'driver=bridge' --format "{{.Name}}")
for i in $(echo $networks)
do
	subnet=$(docker network inspect $i --format "{{(index .IPAM.Config 0).Subnet}}")
	sudo route -q add "$subnet" $hostGateway
done