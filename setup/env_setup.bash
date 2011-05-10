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
# Sitemap - NOTE This installation actually errors out for readme, but code does get installed.
#pip install "http://www.florian-diesch.de/software/apesmit/dist/apesmit-0.01.tar.gz"

# Custom requirements for your app
source "$SITE_CODE_DIR/setup/custom_setup.bash"
