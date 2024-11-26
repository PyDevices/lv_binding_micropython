#!/usr/bin/env bash

GIT_DIR=$(pwd)/..
PORT_DIR=$GIT_DIR/micropython/ports/unix
MODULES=$GIT_DIR
MANIFEST=$GIT_DIR/pydisplay/manifest.py

BUILD_DIR=$PORT_DIR/build-standard

set -e

pushd $PORT_DIR
make -j clean
make -j submodules
make -j USER_C_MODULES=$MODULES FROZEN_MANIFEST=$MANIFEST
popd

echo
echo "The firmware is:  $BUILD_DIR/micropython"
echo
read -p "Do you want to create a link to the firmware as ~/bin/lv? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    mkdir -p ~/bin
    ln -s $BUILD_DIR/micropython ~/bin/lv
    echo "Link created as ~/bin/lv"
fi
