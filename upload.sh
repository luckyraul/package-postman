#!/bin/sh

if [ -f equal ]; then
  echo "Equal game"
  exit 0;
fi

RELEASE=$(echo postman_*.deb)
upload_package upload public_apt "$RELEASE"
