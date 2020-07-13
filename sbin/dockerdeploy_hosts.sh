#!/usr/bin/env bash

set -e
#set -x

which -s hostman || pip install pyhostman

rlec_containers=$(docker ps --format '{{.Label "com.docker.compose.project"}} {{.Names}}'|grep '^rlec\b'|awk '{print $2}')

echo "$rlec_containers" | while read -r container
do
  address=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end }}' "$container")
  echo "$address" "$container"
  sudo hostman add -f "$address" "$container"
done