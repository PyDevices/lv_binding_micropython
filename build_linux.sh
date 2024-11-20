#!/usr/bin/env bash

GIT_DIR=$(pwd)/..
PORT_DIR=$GIT_DIR/micropython/ports/unix
MODULES=/home/brad/gh
MANIFEST=$GIT_DIR/pydisplay/manifest.py

BUILD_DIR=$PORT_DIR/build-standard

set -e

pushd $PORT_DIR
make -j clean
make -j submodules
make -j USER_C_MODULES=$MODULES # FROZEN_MANIFEST=$MANIFEST
popd

echo
echo "The firmware is:  $BUILD_DIR/micropython"
echo
