#!/bin/sh

if [ -f equal ]; then
  echo "Equal game"
  exit 0;
fi

RELEASE=$(echo postman_*.deb)
upload_package upload --distro all public_apt "$RELEASE"
