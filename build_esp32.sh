#!/usr/bin/env bash

GIT_DIR=$(pwd)/..
PORT_DIR=$GIT_DIR/micropython/ports/esp32
BOARD=ESP32_GENERIC_S3
# VARIANT=SPIRAM_OCT
VARIANT=
# MODULES=$GIT_DIR/pydisplay_cmods/modules.cmake  # both pydisplay_cmods and lv_binding_micropython
# MODULES=$GIT_DIR/pydisplay_cmods/src/pydisplay.cmake  # only pydisplay_cmods
# MODULES=$GIT_DIR/lv_binding_micropython/lvgl.cmake  # only lv_binding_micropython
MODULES=$GIT_DIR/lvmp/lvmp.cmake  # only lvmp
MANIFEST=$GIT_DIR/pydisplay/manifest.py
IDF_DIR=$GIT_DIR/esp-idf
BUILD_DIR=$PORT_DIR/build
if [ -n "$BOARD" ]; then
    BUILD_DIR=$BUILD_DIR-$BOARD
fi
if [ -n "$VARIANT" ]; then
    BUILD_DIR=$BUILD_DIR-$VARIANT
fi

set -e

. $IDF_DIR/export.sh
pushd $PORT_DIR
make -j BOARD=$BOARD BOARD_VARIANT=$VARIANT clean
make -j BOARD=$BOARD BOARD_VARIANT=$VARIANT submodules
make -j BOARD=$BOARD BOARD_VARIANT=$VARIANT all USER_C_MODULES=$MODULES # FROZEN_MANIFEST=$MANIFEST
popd

echo
echo "To flash the firmware run:"
echo "esptool -b 460800 --before default_reset --after hard_reset write_flash 0x0 $BUILD_DIR/firmware.bin"
echo
echo "Put your device in bootload mode and"
echo "press Y to flash the firmware now:"
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    esptool -b 460800 --before default_reset --after hard_reset write_flash 0x0 $BUILD_DIR/firmware.bin
fi
