#!/bin/bash

## Environment ##

SITE_CODE_DIR=$PWD
APP_NAME="flask_application"

source "$SITE_CODE_DIR/setup/bashutils.bash"

## Assumptions ##

[[ -f "$SITE_CODE_DIR/$APP_NAME/__init__.py" ]] || critical "$SITE_CODE_DIR/$APP_NAME/__init__.py is missing"

## Main ##

# TODO Your code goes here

