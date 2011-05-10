#!/bin/bash

## Check Python version ##

if [[ $(python -c "import sys; print (2,6) <= sys.version_info < (3,0)") != "True" ]]
then
    echo "Need at least Python 2.6"
    exit 1
fi

## Take website name as command line argument ##

SITE_NAME=$1
shift

if [[ -z "$SITE_NAME" ]]
then
    echo "Usage: $0 SITE_NAME"
    exit 1
fi

ADMIN_EMAIL="admin@$SITE_NAME"

APP_NAME="flask_application"

## Utilities ##

# http://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/
txtred=$(tput setaf 1)
txtgreen=$(tput setaf 2)
txtyellow=$(tput setaf 3)
txtreset=$(tput sgr0)
txtunderline=$(tput sgr 0 1)

common_prefix="! "

function info
{
    echo "$txtgreen$common_prefix$@$txtreset"
}

function warning
{
    echo "$txtyellow$common_prefix$@$txtreset"
}

function critical
{
    echo "$txtunderline$txtred$common_prefix$@$txtreset"
    exit 1
}

# /home/foo -> \/home\/foo ... so that sed does not get confused.
LINUX_HOME="/home/$USER"
LINUX_HOME_ESCAPED=${LINUX_HOME//\//\\/}

## Environment ##

SITE_CODE_DIR=$PWD

## Assumptions ##

[[ -f "$SITE_CODE_DIR/$APP_NAME/__init__.py" ]] || critical "$SITE_CODE_DIR/$APP_NAME/__init__.py is missing"

## Main ##

# Flask, assets, forms, scripts, email, caching, etc.
info "Installing Python packages"
pip install Flask Flask-Assets cssmin Flask-WTF Flask-Script Flask-Mail Flask-Cache || critical "Could not install Flask and dependencies"
# Sitemap - NOTE This installation actually errors out for readme, but code does get installed.
#pip install "http://www.florian-diesch.de/software/apesmit/dist/apesmit-0.01.tar.gz"

info "NOTE This script assumes that you already have your system dependencies such as Memcache, MongoDB, etc. installed on your local machine already."
info "NOTE The script will install system dependencies on the server when you do fab server_setup though."

info "Domain name --> $SITE_NAME"

cd "$SITE_CODE_DIR/$APP_NAME"

info "Generating secret key and updating config file"
SECRET_KEY=`python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789@#$%^&*(-_=+)") for i in range(50)])'`
sed -i "" -e "s/{SECRET_KEY}/$SECRET_KEY/g" -e "s/{SITE_NAME}/$SITE_NAME/g" "config.py" || critical "Could not fill $APP_NAME/config.py"

cd "$SITE_CODE_DIR/setup"

# WSGI file
# http://flask.pocoo.org/docs/deploying/mod_wsgi/
info "Generating WSGI file"
if [[ ! -f "$APP_NAME.wsgi" ]]
then
    git mv run.wsgi "$APP_NAME.wsgi"
    sed -i "" -e "s/{SITE_NAME}/$SITE_NAME/g" -e "s/{APP_NAME}/$APP_NAME/g" -e "s/{HOME}/$LINUX_HOME_ESCAPED/g" "$APP_NAME.wsgi" || critical "Could not fill $APP_NAME.wsgi"
fi

info "Updating fabfile"
cd "$SITE_CODE_DIR"
sed -i "" -e "s/{SITE_NAME}/$SITE_NAME/g"  "fabfile.py" || critical "Could not fill fabfile.py"

info "Updating Apache site configuration"
cd "$SITE_CODE_DIR/setup"
sed -i "" -e "s/{SITE_NAME}/$SITE_NAME/g" -e "s/{HOME}/$LINUX_HOME_ESCAPED/g" -e "s/{APP_NAME}/$APP_NAME/g" -e "s/{ADMIN_EMAIL}/$ADMIN_EMAIL/g" -e "s/{USER}/$USER/g" apache_site_entry || critical "Could not fill apache config file"

info "Setting up the new git repo"
cd "$SITE_CODE_DIR"
sed -i "" -e "s/origin/flask_boilerplate/g" ".git/config"
git commit -a -m "Initial commit for site $SITE_NAME"

info "Fetching submodules"
bash $SITE_CODE_DIR/setup/copy_html5.bash $SITE_CODE_DIR

info "Setting up output directory for Flask-Assets"
mkdir -p $SITE_CODE_DIR/$APP_NAME/static/gen/

info "DONE"
