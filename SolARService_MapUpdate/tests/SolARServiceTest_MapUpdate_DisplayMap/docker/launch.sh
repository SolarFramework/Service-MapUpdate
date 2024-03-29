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

# Get host IP for display
if [ "$2" ]
then
    echo "Display IP = $2"
else
    echo "You need to give host IP address for display as second parameter!"
    exit 1
fi

# Set Display IP
export DISPLAY=$2:0.0

# Get backup/restore options
if [ "$3" ]
then
        echo "Set option = $3"
        export MAP_OPTION=$3
else
        echo "You can specify global map backup or restore options with keywords BACKUPMAP or RESTOREMAP"
fi

# Set application log level
# Log level expected: DEBUG, CRITICAL, ERROR, INFO, TRACE, WARNING
export SOLAR_LOG_LEVEL=INFO

docker rm -f solarservicemapupdatedisplaymapclient
docker run -it -d -v $PWD/map_backup:/SolARServiceMapUpdateDisplayMapClient/MapBackup -e DISPLAY -e MAPUPDATE_SERVICE_URL -e MAP_OPTION -e SOLAR_LOG_LEVEL -e "SERVICE_NAME=SolARServiceMapUpdateDisplayMapClient" -v /tmp/.X11-unix:/tmp/.X11-unix --net=host --log-opt max-size=50m -e "SERVICE_TAGS=SolAR" --name solarservicemapupdatedisplaymapclient artwin/solar/services/map-update-displaymap-client:latest
