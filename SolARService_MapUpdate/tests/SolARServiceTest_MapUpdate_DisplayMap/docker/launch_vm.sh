#!/bin/sh

# Get Map Update Service URL from parameters
if [ "$1" ]
then
    echo "Map Update Service URL = $1"
else
    echo "You need to give Map Update Service URL as parameter!"
    exit 1
fi

# Set MapUpdate Service URL
export MAPUPDATE_SERVICE_URL=$1

# Set Display
export DISPLAY=${DISPLAY}
xhost local:docker

# Get backup/restore options
if [ "$2" ]
then
        echo "Set option = $2"
        export MAP_OPTION=$2
else
        echo "You can specify global map backup or restore options with keywords BACKUPMAP or RESTOREMAP"
fi

# Set application log level
# Log level expected: DEBUG, CRITICAL, ERROR, INFO, TRACE, WARNING
export SOLAR_LOG_LEVEL=INFO

docker rm -f solarservicemapupdatedisplaymapclient
docker run -it -d -v $PWD/map_backup:/SolARServiceMapUpdateDisplayMapClient/MapBackup -e DISPLAY -e MAPUPDATE_SERVICE_URL -e MAP_OPTION -e SOLAR_LOG_LEVEL -e "SERVICE_NAME=SolARServiceMapUpdateDisplayMapClient" -v /tmp/.X11-unix:/tmp/.X11-unix --net=host --log-opt max-size=50m -e "SERVICE_TAGS=SolAR" --name solarservicemapupdatedisplaymapclient artwin/solar/services/map-update-displaymap-client:latest
