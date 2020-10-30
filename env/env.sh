#!/bin/bash
set -e

SCRIPT_DIR=$(dirname $(realpath $0))
GST_BUILD_DIR=${HOME}/.config/vinci/gstreamer_build/gst-build

source $SCRIPT_DIR/source_virtualenv

LIB_DIR=$(realpath $SCRIPT_DIR/../../../../lib)
VINCI_GSTREAMER_DIR=$(realpath $SCRIPT_DIR/../../../../lib/vinci/gstreamer)
PROJ_DIR=$(realpath $SCRIPT_DIR/..)


if [ -e "$GST_BUILD_DIR" ]; then
    eval $($GST_BUILD_DIR/gst-env.py  --only-environment)
fi

GST_PLUGIN_PATH=$GST_PLUGIN_PATH:$VINCI_GSTREAMER_DIR \
    PYTHONPATH=$PYTHONPATH:$PROJ_DIR:$LIB_DIR "$@"
