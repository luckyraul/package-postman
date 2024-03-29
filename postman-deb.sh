#!/bin/sh

if [ -f equal ]; then
  echo "Equal game"
  exit 0;
fi

ls postman*.tar.gz > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Removing old Postman tarballs"
  rm -f $(ls postman*.tar.gz)
fi

echo "Testing Postman version"
rm -fR Postman
curl https://dl.pstmn.io/download/latest/linux64 | tar -xz
version=$(jq -r .version Postman/app/resources/app/package.json)
echo "Most recent Postman version $version"

current=$(dpkg-query --showformat='${Version}' --show postman 2> /dev/null)
if [ $? -gt 0 ]; then
  echo "Postman is not installed"
else
  echo "Installed version V$current"

  if [ "$current" = "$version" ]; then
    echo "The most recent version of Postman is currently installed"
    exit
  else
    echo "Updating Postman to the latest version"
  fi
fi

echo "Downloading latest Postman tarball"

curl https://dl.pstmn.io/download/latest/linux64 --output postman.tar.gz

if [ $? -gt 0 ]; then
  echo "Failed to download Postman tarball"
  exit
fi

if [ -d "Postman" ]; then
  echo "Removing old 'Postman/'"
  rm -rf "Postman/"
fi

echo "Extracting Postman tarball"
tar -xf $(ls postman*.tar.gz)

if [ $? -gt 0 ]; then
  echo "Failed to extract Postman tarball"
  exit
fi

if [ -d "postman_$version" ]; then
  echo "Removing old 'postman_$version/'"
  rm -rf "postman_$version/"
fi

echo "Creating 'postman_$version' folder structure and files"
mkdir -m 0755 -p "postman_$version"

mkdir -m 0755 -p "postman_$version/usr/share/applications"
touch "postman_$version/usr/share/applications/postman.desktop"

mkdir -m 0755 -p "postman_$version/usr/share/icons/hicolor/128x128/apps"

mkdir -m 0755 -p "postman_$version/opt/postman"

mkdir -m 0755 -p "postman_$version/DEBIAN"
touch "postman_$version/DEBIAN/control" "postman_$version/DEBIAN/postinst" "postman_$version/DEBIAN/prerm"

echo "Copying files"
cp "Postman/app/resources/app/assets/icon.png" "postman_$version/usr/share/icons/hicolor/128x128/apps/postman.png"
cp -R "Postman/"* "postman_$version/opt/postman/"

echo "Testing whether to use '-e'"
lines=$(echo "\n" | wc -l)
e=""
if [ $lines -eq 1 ]; then
  echo "'-e' is required"
  e="-e"
else
  echo "'-e' is not required"
fi

echo "Writing files"
echo $e "[Desktop Entry]\nType=Application\nName=Postman\nGenericName=API Tester\nComment=The Collaboration Platform for API Development\nIcon=postman\nExec=postman\nPath=/opt/postman\nCategories=Development;" > "postman_$version/opt/postman/postman.desktop"
echo $e "Package: postman\nVersion: $version\nSection: devel\nPriority: optional\nArchitecture: amd64\nDepends: gconf2, libgtk2.0-0, desktop-file-utils\nOptional: libcanberra-gtk-module\nMaintainer: Mygento Team\nDescription: Postman\n The Collaboration Platform for API Development" > "postman_$version/DEBIAN/control"
echo $e "if [ -f \"/usr/bin/postman\" ]; then\n\tsudo rm -f \"/usr/bin/postman\"\nfi\n\nsudo ln -s \"/opt/postman/Postman\" \"/usr/bin/postman\"\n\ndesktop-file-install \"/opt/postman/postman.desktop\"" > "postman_$version/DEBIAN/postinst"
echo $e "if [ -f \"/usr/bin/postman\" ]; then\n\tsudo rm -f \"/usr/bin/postman\"\nfi" > "postman_$version/DEBIAN/prerm"

echo "Setting modes"

chmod 0644 "postman_$version/usr/share/applications/postman.desktop"

chmod 0775 "postman_$version/DEBIAN/control"
chmod 0775 "postman_$version/DEBIAN/postinst"
chmod 0775 "postman_$version/DEBIAN/prerm"

echo "Validating modes"
nc=""
if [ $(stat -c "%a" "postman_$version/DEBIAN/control") != "775" ]; then
  echo "File modes are invalid, calling 'dpkg-deb' with '--nocheck'"
  nc="--nocheck"
else
  echo "File modes are valid"
fi

if [ -f "postman_$version.deb" ]; then
  echo "Removing old 'postman_$version.deb'"
  rm -f "postman_$version.deb"
fi

echo "Building 'postman_$version.deb'"
dpkg-deb $nc -b "postman_$version" > /dev/null

if [ $? -gt 0 ]; then
  echo "Failed to build 'postman_$version.deb'"
  exit
fi

echo "Cleaning up"
rm -f $(ls postman*.tar.gz)
rm -rf "Postman/"
rm -rf "postman_$version/"
