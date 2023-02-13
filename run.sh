#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

HOST_NAME="warp-socks"

if [[ "$(docker images -q "${HOST_NAME}:latest" 2> /dev/null)" == "" || "$1" != "" ]]; then
  docker build -t "${HOST_NAME}:latest" "${DIR}/build"
  if [ $? -eq 0 ]; then
      echo 'Build done'
  else
      echo 'Build failed'
      exit 1
  fi
fi

docker container inspect "${HOST_NAME}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  docker stop "${HOST_NAME}"
  docker rm "${HOST_NAME}"
fi

docker run -d --restart=unless-stopped --name "${HOST_NAME}" --hostname "${HOST_NAME}" \
  -p 10800:1080 \
  "${HOST_NAME}:latest"

sleep 5

docker exec -it "${HOST_NAME}" warp-cli register
docker exec "${HOST_NAME}" warp-cli set-mode proxy
docker exec "${HOST_NAME}" warp-cli set-proxy-port 1080
docker exec "${HOST_NAME}" warp-cli connect
