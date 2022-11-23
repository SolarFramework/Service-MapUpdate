#!/bin/sh

# Get service port from parameters
if [ "$1" ]
then
    echo "Map Update service port = $1"
else
    echo "You need to give Map Update service port as first parameter!"
    exit 1
fi

# Set Map Update service external URL
export SERVER_EXTERNAL_URL=172.17.0.1:$1

# Get Service Manager URL from parameters
if [ "$2" ]
then
    echo "Service Manager URL = $2"
else
    echo "You need to give Service Manager URL as parameter!"
    exit 1
fi

# Set Service Manager URL
export SERVICE_MANAGER_URL=$2

# Set application log level
# Log level expected: DEBUG, CRITICAL, ERROR, INFO, TRACE, WARNING
export SOLAR_LOG_LEVEL=INFO

docker rm -f solarservicemapupdatecuda
docker run --gpus all -d -p $1:8080 -v volume_map_cuda:/SolARServiceMapUpdate/data/maps/globalMapCuda -e SERVER_EXTERNAL_URL -e SERVICE_MANAGER_URL -e SOLAR_LOG_LEVEL -e "SERVICE_NAME=SolARServiceMapUpdateCuda" --log-opt max-size=50m -e "SERVICE_TAGS=SolAR" --name solarservicemapupdatecuda artwin/solar/services/map-update-cuda-service:latest
