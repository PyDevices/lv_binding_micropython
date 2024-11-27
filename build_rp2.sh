#!/usr/bin/env bash

BOARD=RPI_PICO
VARIANT=

REPO_DIR=$(pwd)
PORT_DIR=$REPO_DIR/../micropython/ports/rp2
MODULES=$REPO_DIR/usermod/micropython.cmake
MANIFEST=$REPO_DIR/../pydisplay/manifest.py
BUILD_DIR=$PORT_DIR/build
if [ -n "$BOARD" ]; then
    BUILD_DIR=$BUILD_DIR-$BOARD
fi
if [ -n "$VARIANT" ]; then
    BUILD_DIR=$BUILD_DIR-$VARIANT
fi

set -e

pushd $PORT_DIR
make -j BOARD=$BOARD BOARD_VARIANT=$VARIANT clean
make -j BOARD=$BOARD BOARD_VARIANT=$VARIANT submodules
make -j BOARD=$BOARD BOARD_VARIANT=$VARIANT all USER_C_MODULES=../../../lv_micropython_cmod/usermod/micropython.cmake # FROZEN_MANIFEST=$MANIFEST
popd

echo
echo "The firmware is:  $BUILD_DIR/firmware.uf2"
echo
