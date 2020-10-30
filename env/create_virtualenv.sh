#!/bin/bash
set -ex

SCRIPT_DIR=$(dirname $(realpath $0))
python_version=3.7

virtualenv_dir=~/.config/vinci/virtualenvs/kenburns

# If the virtualenv already exists, just update requirements.
if [ -e "$virtualenv_dir" ]; then
	echo "$virtualenv_dir already exists. We'll just update requirements."
else
    /usr/bin/python${python_version} -m venv "$virtualenv_dir"

    # pip also needs an upgrade, for some requirements (hardcoded version here for now)
    $virtualenv_dir/bin/pip install --upgrade pip==20.2.4
fi

# Now install requirements.
$virtualenv_dir/bin/pip install $pip_verbose_flag -r "$SCRIPT_DIR/../requirements.txt"
