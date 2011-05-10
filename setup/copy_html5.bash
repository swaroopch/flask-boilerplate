#!/usr/bin/env bash

## Environment ##

SITE_CODE_DIR=$1
shift

[[ -n "$SITE_CODE_DIR" ]] || exit 1

source "$SITE_CODE_DIR/setup/bashutils.bash"

APP_NAME="flask_application"
HTML5_DIR="$SITE_CODE_DIR/html5"
STATIC_DIR="$SITE_CODE_DIR/$APP_NAME/static"
TEMPLATE_DIR="$SITE_CODE_DIR/$APP_NAME/templates"
PUBLIC_DIR="$SITE_CODE_DIR/../../public"

## Main ##

cd $SITE_CODE_DIR
git submodule update --init --recursive

cp $HTML5_DIR/404.html $TEMPLATE_DIR/404.html

cp $HTML5_DIR/robots.txt $STATIC_DIR/robots.txt

cp $HTML5_DIR/apple-touch-icon.png $STATIC_DIR/apple-touch-icon.png
cp $HTML5_DIR/favicon.ico $STATIC_DIR/favicon.ico

mkdir -p $STATIC_DIR/js
cp -r $HTML5_DIR/js/* $STATIC_DIR/js/

mkdir -p $STATIC_DIR/css
cp $HTML5_DIR/css/* $STATIC_DIR/css/

cp $HTML5_DIR/.htaccess $PUBLIC_DIR/.htaccess

