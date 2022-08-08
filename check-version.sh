#!/bin/sh
rm -fR Postman
curl https://dl.pstmn.io/download/latest/linux64 | tar -xz
version=$(jq -r .version Postman/app/resources/app/package.json)
latest=`cat latest`

echo "Most recent Postman version $version"
echo "Comparing with version $latest"
if [ "$version" = "$latest" ]; then echo "EQUAL"; touch equal; else echo "NOT EQUAL";fi;
