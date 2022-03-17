
Version="0.11.0"

if [ -z "$1" ]
then
   filename="SolARService_MapUpdate_$Version"
else
   filename=$1
fi

CONFIG_FILES=`find . -not \( -path "./bin" -prune \) -type f \( -name "SolARService*_conf.xml" -or -name "SolARServiceTest*_conf.xml" \)`

echo "**** Install dependencies locally"
remaken install packagedependencies.txt
remaken install packagedependencies.txt -c debug

echo "**** Bundle dependencies in bin folder"
for file in $CONFIG_FILES
do
   echo "install dependencies for config file: $file"
   remaken bundleXpcf $file -d ./bin/x86_64/shared/release -s modules
   remaken bundleXpcf $file -d ./bin/x86_64/shared/debug -s modules -c debug
done

zip --symlinks -r "./bin/${filename}_release.zip" ./bin/x86_64/shared/release ./README.md ./installData.sh ./LICENSE
zip --symlinks -r "./bin/${filename}_debug.zip" ./bin/x86_64/shared/debug ./README.md ./installData.sh ./LICENSE 
