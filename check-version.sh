#!/bin/sh

targetName=$(curl -sI "https://dl.pstmn.io/download/latest/linux64" | grep -i "content-disposition" | awk -F '=' '{ print $2 }')
versionMaj=$(echo "$targetName" | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $1 }')
versionMin=$(echo "$targetName" | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $2 }')
versionRev=$(echo "$targetName" | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $3 }')
version="$versionMaj.$versionMin.$versionRev"
latest=`cat latest`

echo "Most recent Postman version $version"
echo "Comparing with version $latest"
if [ "$version" = "$latest" ]; then echo "EQUAL"; touch equal; else echo "NOT EQUAL";fi;
