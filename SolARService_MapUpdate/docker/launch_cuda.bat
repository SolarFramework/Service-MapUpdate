ECHO off

REM Set application log level
REM Log level expected: DEBUG, CRITICAL, ERROR, INFO, TRACE, WARNING
SET SOLAR_LOG_LEVEL=INFO

docker rm -f solarservicemapupdatecuda
docker run --gpus all -d -p 60053:8080 -v volume_map_cuda:/SolARServiceMapUpdate/data/maps/globalMapCuda -e SOLAR_LOG_LEVEL -e "SERVICE_NAME=SolARServiceMapUpdateCuda" --log-opt max-size=50m -e "SERVICE_TAGS=SolAR" --name solarservicemapupdatecuda artwin/solar/services/map-update-cuda-service:latest
