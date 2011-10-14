#!/bin/bash

## Environment ##

SITE_CODE_DIR=$PWD
APP_NAME="flask_application"

source "$SITE_CODE_DIR/setup/bashutils.bash"

## Check Python version ##

if [[ $(python -c "import platform; print ('2','6') <= platform.python_version_tuple() < ('3','0')") != "True" ]]
then
    critical "Need at least Python 2.6"
fi

## Take website name as command line argument ##

SITE_NAME=$1
shift

if [[ -z "$SITE_NAME" ]]
then
    critical "Usage: $0 SITE_NAME"
fi

ADMIN_EMAIL="admin@$SITE_NAME"

# /home/foo -> \/home\/foo ... so that sed does not get confused.
LINUX_HOME="/home/$USER"
LINUX_HOME_ESCAPED=${LINUX_HOME//\//\\/}

## Assumptions ##

[[ -f "$SITE_CODE_DIR/$APP_NAME/__init__.py" ]] || critical "$SITE_CODE_DIR/$APP_NAME/__init__.py is missing"

## Main ##

info "Domain name --> $SITE_NAME"

cd "$SITE_CODE_DIR/$APP_NAME"

info "Generating secret key and updating config file"
SECRET_KEY=`python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789@#$%^*(-_=+)") for i in range(50)])'`
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

info "Removing LICENSE and README files"
git rm $SITE_CODE_DIR/LICENSE.txt
git rm $SITE_CODE_DIR/README.textile

info "Setting up the new git repo"
cd "$SITE_CODE_DIR"
#sed -i "" -e "s/origin/flask_boilerplate/g" ".git/config"
git commit -a -m "Initial commit for site $SITE_NAME"
