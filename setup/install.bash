#!/usr/bin/env bash

## Check Operating system ##

# This script assumes Ubuntu directory structure.
# (The directory structure is different for different Linux distributions.)

function die_without_linux
{
    echo "This script works only with Ubuntu Linux and Bash."
    exit 1
}

[[ "$OSTYPE" == "linux-gnu" ]]      || die_without_linux
[[ $(which lsb_release) != "" ]]    || die_without_linux
[[ $(lsb_release -i) =~ "Ubuntu" ]] || die_without_linux
[[ ${SHELL} =~ "bash" ]]            || die_without_linux
[[ "${BASH_VERSINFO[0]}" -ge "4" ]] || die_without_linux

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
HOME_ESCAPED=${HOME//\//\\/}

function install_apache_package
{
    name=$1
    shift
    [[ -z "$name" ]] && critical "Code Error: Called install_apache_package without a name"

    [[ -z $(dpkg -l | fgrep -i $name) ]] && ( sudo apt-get install $name || critical "Could not apt-get $name package" )
}

## Environment ##

script_path=`readlink -f $0`
BOILERPLATE=`readlink -f $(dirname $script_path)/..`

## Assumptions ##

[[ -f "$BOILERPLATE/$APP_NAME/__init__.py" ]] || critical "$BOILERPLATE/$APP_NAME/__init__.py is missing"

SITE_TOP_DIR="$HOME/web/$SITE_NAME"

[[ ! -d "$SITE_TOP_DIR" ]] || critical "$SITE_TOP_DIR already present"
mkdir -p $SITE_TOP_DIR/{public,private,log,backup}

SITE_CODE_DIR="$SITE_TOP_DIR/private/$SITE_NAME"
SITE_PUBLIC_DIR="$SITE_TOP_DIR/public"

## Main ##
#set -x

info "Domain name --> $SITE_NAME"

info "Checking Apache packages"
sudo apt-get update # Otherwise, a fresh 64-bit system gives 404 for wsgi deb package...
if [[ -z $(dpkg -l | fgrep -i libapache2-mod-wsgi) ]]
then
    sudo apt-get install apache2 apache2.2-common apache2-mpm-prefork apache2-utils libapache2-mod-wsgi || critical "Could not install Apache packages"
fi

info "Checking Python environment"
if [[ -z $(dpkg -l | fgrep -i python-setuptools) ]]
then
    sudo apt-get install python-setuptools || critical "Could not install setuptools package"
    sudo easy_install virtualenv==tip
fi
PYENV="$HOME/local/pyenv"
if [[ ! -d "$PYENV" ]]
then
    mkdir -p $HOME/local
    cd $HOME/local
    export VIRTUALENV_USE_DISTRIBUTE=1
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    virtualenv pyenv
    source pyenv/bin/activate
    info "Activating $PYENV python environment in your ~/.bashrc"
    echo >> "$HOME/.bashrc" && echo "source $PYENV/bin/activate" >> "$HOME/.bashrc"
    easy_install pip
fi

info "Cloning flask_boilerplate repository"
git clone $BOILERPLATE $SITE_CODE_DIR || critical "Could not clone $BOILERPLATE git repository"
cd $SITE_CODE_DIR

info "Installing essential Apache build packages and Python library dependencies"

# Flask
pip install Flask || critical "Could not download/install Flask module"

# Fabric
pip install Fabric

cd "$SITE_CODE_DIR/$APP_NAME"

info "Updating config file"
sed -i -e "s/{SITE_NAME}/$SITE_NAME/g" config.py

info "Updating homepage template"
sed -i -e "s/{SITE_NAME}/$SITE_NAME/g" templates/index.html

info "Generating secret key"
SECRET_KEY=`python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789@#$%^&*(-_=+)") for i in range(50)])'`
sed -i -e "s/{SECRET_KEY}/$SECRET_KEY/g" -e "s/{SITE_NAME}/$SITE_NAME/g" "config.py" || critical "Could not fill $APP_NAME/config.py"

cd "$SITE_CODE_DIR/setup"

# WSGI file
# http://flask.pocoo.org/docs/deploying/mod_wsgi/
info "Generating WSGI file"
if [[ ! -f "$APP_NAME.wsgi" ]]
then
    cp run.wsgi "$APP_NAME.wsgi"
    sed -i -e "s/{SITE_NAME}/$SITE_NAME/g" -e "s/{APP_NAME}/$APP_NAME/g" -e "s/{HOME}/$HOME_ESCAPED/g" "$APP_NAME.wsgi" || critical "Could not fill $APP_NAME.wsgi"
fi

info "Updating the fabfile"
cd "$SITE_CODE_DIR"
sed -i -e "s/{SITE_NAME}/$SITE_NAME/g"  "fabfile.py" || critical "Could not fill fabfile.py"

info "Checking static directory symlink in public folder"
if [[ ! -L "$SITE_PUBLIC_DIR/static" ]]
then
    ln -s "$SITE_CODE_DIR/$APP_NAME/static" "$SITE_PUBLIC_DIR/static" || critical "Could not symlink static folder to public"
fi

info "Adding Apache site configuration"
APACHE_SITE_CONFIG="/etc/apache2/sites-available/$SITE_NAME"
if [[ ! -f $APACHE_SITE_CONFIG ]]
then
    cp apache_site_entry $SITE_NAME
    sed -i -e "s/{SITE_NAME}/$SITE_NAME/g" -e "s/{HOME}/$HOME_ESCAPED/g" -e "s/{APP_NAME}/$APP_NAME/g" -e "s/{ADMIN_EMAIL}/$ADMIN_EMAIL/g" $SITE_NAME || critical "Could not fill apache config file"
    sudo cp $SITE_NAME $APACHE_SITE_CONFIG || critical "Could not copy apache config file to apache sites-available directory"
    sudo /usr/sbin/apache2ctl configtest || critical "Apache config file check failed"
    sudo a2ensite $SITE_NAME || critical "Could not enable $SITE_NAME site"
    sudo a2enmod headers # Needed for some features of the .htaccess provided by the HTML5-boilerplate
    sudo /etc/init.d/apache2 restart || critical "Apache restart failed"
fi

info "Setting up the new git repo"
cd "$SITE_CODE_DIR"
sed -i -e "s/origin/flask_boilerplate/g" ".git/config"
git add .

cd "$SITE_CODE_DIR/setup"
git rm apache_site_entry
git rm run.wsgi
git rm install.bash

cd "$SITE_CODE_DIR"
git rm README.rst
git rm LICENSE.txt

git commit -m "Initial commit for site $SITE_NAME"

info "Fetching submodules"
bash $SITE_CODE_DIR/setup/copy_html5.bash $SITE_CODE_DIR

info "Switching to develop branch"
cd "$SITE_CODE_DIR"
git co develop

info "DONE"

info "Start adding your actual website code to $SITE_CODE_DIR/$APP_NAME/controllers/frontend.py and see the changes live on $SITE_NAME !"
info "You can 'git clone' the repo from $SITE_CODE_DIR/$APP_NAME to your local box, make changes, and then run 'fab deploy' to update the site!"
#set +x

