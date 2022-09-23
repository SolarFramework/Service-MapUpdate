#!/bin/sh

## Detect MAPUPDATE_SERVICE_URL var and use its value 
## to set the Map Update service URL in XML configuration file

cd /SolARServiceMapUpdateDisplayMapClient

if [ -z "$MAPUPDATE_SERVICE_URL" ]
then
    echo "Error: You must define MAPUPDATE_SERVICE_URL env var with the MapUpdate Service URL"
    exit 1 
else
    echo "MAPUPDATE_SERVICE_URL defined: $MAPUPDATE_SERVICE_URL"
fi

echo "Try to replace the MapUpdate Service URL in the XML configuration file..."

sed -i -e "s/MAPUPDATE_SERVICE_URL/$MAPUPDATE_SERVICE_URL/g" /.xpcf/SolARServiceTest_MapUpdate_DisplayMap_conf.xml

echo "XML configuration file ready"

export LD_LIBRARY_PATH=.:./modules/

echo "Check map backup/restore options"

if echo $MAP_OPTION | grep -q "BACKUP"
then
    ## Start client with "backup" option
    ./SolARServiceTest_MapUpdate_DisplayMap -f /.xpcf/SolARServiceTest_MapUpdate_DisplayMap_conf.xml -b ./MapBackup
    exit 0
fi

if echo $MAP_OPTION | grep -q "RESTORE"
then
    ## Start client with "restore" option
    ./SolARServiceTest_MapUpdate_DisplayMap -f /.xpcf/SolARServiceTest_MapUpdate_DisplayMap_conf.xml -r ./MapBackup
    exit 0
fi

## Start client
./SolARServiceTest_MapUpdate_DisplayMap -f /.xpcf/SolARServiceTest_MapUpdate_DisplayMap_conf.xml

