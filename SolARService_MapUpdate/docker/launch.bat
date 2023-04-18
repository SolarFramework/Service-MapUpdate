ECHO off

REM Get service port from parameters
IF "%1"=="" (
    ECHO You need to give Map Update service port as first parameter!
    GOTO end
) ELSE (
    ECHO Map Update service port = %1
)

REM Set Map Update service external URL
SET SERVER_EXTERNAL_URL=172.17.0.1:%1

REM Get Service Manager URL from parameters
IF "%2"=="" (
    ECHO You need to give Service Manager URL as second parameter!
    GOTO end
) ELSE (
    ECHO Service Manager Service URL = %2
)

REM Set Service Manager URL
SET SERVICE_MANAGER_URL=%2

REM Set application log level
REM Log level expected: DEBUG, CRITICAL, ERROR, INFO, TRACE, WARNING
SET SOLAR_LOG_LEVEL=INFO

docker rm -f solarservicemapupdate
docker run -d -p %1:8080 -v volume_map:/SolARServiceMapUpdate/data/maps/globalMap -e SERVER_EXTERNAL_URL -e SERVICE_MANAGER_URL -e SOLAR_LOG_LEVEL -e "SERVICE_NAME=SolARServiceMapUpdate" --log-opt max-size=50m -e "SERVICE_TAGS=SolAR" --name solarservicemapupdate artwin/solar/services/map-update-service:latest

:end
