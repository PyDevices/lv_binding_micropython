#!/usr/bin/env bash

set -e

REPO_DIR=$(pwd)
PORT_DIR=$REPO_DIR/../micropython/ports/unix
MODULES=$REPO_DIR/..
MANIFEST=$REPO_DIR/manifest.py
BUILD_DIR=$PORT_DIR/build-standard
COPY_TO=~/bin/lv

pushd $PORT_DIR
make -j clean
make -j submodules
make -j USER_C_MODULES=$MODULES FROZEN_MANIFEST=$MANIFEST
popd

echo
echo "The executable is:  $BUILD_DIR/micropython"
echo

echo "Do you want to copy the executable to $COPY_TO?"
read -p "[y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p ~/bin
    cp $BUILD_DIR/micropython $COPY_TO
    echo "Executable copied to $COPY_TO"
fi
echo
