#!/bin/bash
# Setup this environment and run python on your command line.
set -e

SCRIPT_DIR=$(realpath $(dirname $0))

$SCRIPT_DIR/env.sh python "$@"
