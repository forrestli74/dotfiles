#!/usr/bin/env bash
set -e

# location: https://github.com/gitpod-io/openvscode-server/releases/tag/openvscode-server-v1.62.3
regex="^location: https:\/\/github.com\/gitpod-io\/openvscode-server\/releases\/tag\/openvscode-server-v\(1\.[0-9]*\.[0-9]*\)\r$"

LATEST=https://github.com/gitpod-io/openvscode-server/releases/latest

# SERVER_VERSION=1.60.0
SERVER_VERSION=$(curl -sI $LATEST | sed -n "s/$regex/\1/ p")

# Change location?
cd ~
FOLDER1=openvscode-server-v${SERVER_VERSION}-linux-x64
FOLDER2=openvscode-server
URL="https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${SERVER_VERSION}/$FOLDER1.tar.gz"
echo Fetching $URL
wget $URL
tar -xzf $FOLDER1.tar.gz
rm $FOLDER1.tar.gz

if [[ -d $FOLDER2 ]]; then
  rm -rf $FOLDER2
fi
mv $FOLDER1 $FOLDER2


