@echo off
:: Download bag of words vocabulary
echo Download bag of word dictionnaries
curl https://github.com/SolarFramework/SolARModuleFBOW/releases/download/fbowVocabulary/fbow_voc.zip -L -o fbow_voc.zip
echo Unzip bag of word dictionnaries
powershell Expand-Archive fbow_voc.zip -DestinationPath .\data\fbow_voc -F
del fbow_voc.zip

curl https://repository.solarframework.org/generic/FbowVoc/popsift_uint8.fbow -L -o .\data\fbow_voc\popsift_uint8.fbow
curl https://repository.solarframework.org/generic/FbowVoc/popsift_uint8_indoor.fbow -L -o .\data\fbow_voc\popsift_uint8_indoor.fbow

:: Download maps
echo Download and install maps
curl https://repository.solarframework.org/generic/maps/hololens/bcomLab/mapLabA_win_0_10_0.zip -L -o mapA.zip
powershell Expand-Archive mapA.zip -DestinationPath .\data\maps -F
del mapA.zip

curl https://repository.solarframework.org/generic/maps/hololens/bcomLab/mapLabB_win_0_10_0.zip -L -o mapB.zip
powershell Expand-Archive mapB.zip -DestinationPath .\data\maps -F
del mapB.zip

:: Download calibration file
echo Download calibration file
curl https://repository.solarframework.org/generic/captures/hololens/hololens_calibration.json -L -o hololens_calibration.json
md .\data\calibrations
move hololens_calibration.json .\data\calibrations\hololens_calibration.json
