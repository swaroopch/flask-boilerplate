#!/bin/bash

## Environment ##

SITE_CODE_DIR=$PWD
APP_NAME="flask_application"

source "$SITE_CODE_DIR/setup/bashutils.bash"

## Assumptions ##

[[ -f "$SITE_CODE_DIR/$APP_NAME/__init__.py" ]] || critical "$SITE_CODE_DIR/$APP_NAME/__init__.py is missing"

## Main ##

# Flask, assets, forms, scripts, email, caching, etc.
echo "Installing Python packages"
pip install Flask Flask-Assets cssmin Flask-WTF Flask-Script Flask-Mail Flask-Cache Fabric python-memcached || critical "Could not install Flask and dependencies"

# Install unittest2 if Python < 2.7
if [[ $(python -c "import platform; print platform.python_version_tuple() < (2,7)") == "True" ]]
then
    pip install unittest2
fi

# Custom requirements for your app
source "$SITE_CODE_DIR/setup/custom_setup.bash"
