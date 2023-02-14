#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

PORT=1080
HOST_NAME="warp-socks"

if [[ "$(docker images -q "${HOST_NAME}:latest" 2> /dev/null)" == "" || "$1" != "" ]]; then
  docker build -t "${HOST_NAME}:latest" "${DIR}"
  if [ $? -eq 0 ]; then
      echo 'Build done'
  else
      echo 'Build failed'
      exit 1
  fi
fi

docker container inspect "${HOST_NAME}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  docker kill "${HOST_NAME}"
  docker rm "${HOST_NAME}"
fi

docker run -d --restart=unless-stopped --name "${HOST_NAME}" \
  -v "${DIR}/entrypoint.sh:/entrypoint.sh:ro" \
  --entrypoint /entrypoint.sh \
  -p "$PORT:1080" \
  "${HOST_NAME}:latest"

sleep 5

docker exec -it "${HOST_NAME}" warp-cli --accept-tos register
docker exec "${HOST_NAME}" warp-cli --accept-tos set-mode proxy
docker exec "${HOST_NAME}" warp-cli --accept-tos set-proxy-port "10800"
docker exec "${HOST_NAME}" warp-cli --accept-tos connect
