ECHO off

REM Get Map Update Service URL from parameters
IF "%1"=="" (
    ECHO You need to give Map Update Service URL as first parameter!
    GOTO end
) ELSE (
    ECHO Map Update Service URL = %1
)

REM Set MapUpdate Service URL
SET MAPUPDATE_SERVICE_URL=%1

REM Get host IP for display
IF "%2"=="" (
    ECHO You need to give host IP address for display as second parameter!
    GOTO end
) ELSE (
    ECHO Set display IP
    SET DISPLAY=%2:0.0
)

ECHO Display IP = %DISPLAY%

ECHO Get backup/restore options
IF "%3"=="" (
    ECHO You can specify global map backup or restore options with keywords BACKUPMAP or RESTOREMAP
) ELSE (
    ECHO Set option = %3
    SET MAP_OPTION=%3
)

REM Set application log level
REM Log level expected: DEBUG, CRITICAL, ERROR, INFO, TRACE, WARNING
SET SOLAR_LOG_LEVEL=INFO

docker rm -f solarservicemapupdatedisplaymapclient
docker run -it -d -v $PWD/map_backup:/SolARServiceMapUpdateDisplayMapClient/MapBackup -e DISPLAY -e MAPUPDATE_SERVICE_URL -e MAP_OPTION -e SOLAR_LOG_LEVEL -e "SERVICE_NAME=SolARServiceMapUpdateDisplayMapClient" -v /tmp/.X11-unix:/tmp/.X11-unix --net=host --log-opt max-size=50m -e "SERVICE_TAGS=SolAR" --name solarservicemapupdatedisplaymapclient artwin/solar/services/map-update-displaymap-client:latest

:end
