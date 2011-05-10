#!/usr/bin/env bash

## Environment ##

SITE_CODE_DIR=$PWD
APP_NAME="flask_application"

source "$SITE_CODE_DIR/setup/bashutils.bash"

## Check Operating system ##

# This script assumes Ubuntu directory structure.
# (The directory structure is different for different Linux distributions.)

[[ "$OSTYPE" == "linux-gnu" ]]      || critical "This script works only with Ubuntu Linux and Bash."
[[ $(which lsb_release) != "" ]]    || critical "This script works only with Ubuntu Linux and Bash."
[[ $(lsb_release -i) =~ "Ubuntu" ]] || critical "This script works only with Ubuntu Linux and Bash."
[[ ${SHELL} =~ "bash" ]]            || critical "This script works only with Ubuntu Linux and Bash."
[[ "${BASH_VERSINFO[0]}" -ge "4" ]] || critical "This script works only with Ubuntu Linux and Bash."

## Check Python version ##

if [[ $(python -c "import sys; print (2,6) <= sys.version_info < (3,0)") != "True" ]]
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

## Utilities ##

function install_apt_package
{
    name=$1
    shift
    [[ -z "$name" ]] && critical "Code Error: Called install_apt_package without a name"

    [[ -z $(dpkg -l | fgrep -i $name) ]] && ( sudo apt-get install $name || critical "Could not apt-get $name package" )
}

## Assumptions ##

[[ -f "$SITE_CODE_DIR/$APP_NAME/__init__.py" ]] || critical "$SITE_CODE_DIR/$APP_NAME/__init__.py is missing"

SITE_TOP_DIR="$HOME/web/$SITE_NAME"

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

info "Installing essential Python library dependencies and other packages"
bash "$SITE_CODE_DIR/setup/env_setup.bash"

info "Checking static directory symlink in public folder"
if [[ ! -L "$SITE_PUBLIC_DIR/static" ]]
then
    ln -s "$SITE_CODE_DIR/$APP_NAME/static" "$SITE_PUBLIC_DIR/static" || critical "Could not symlink static folder to public"
fi

info "Adding Apache site configuration"
cd "$SITE_CODE_DIR/setup"
APACHE_SITE_CONFIG="/etc/apache2/sites-available/$SITE_NAME"
if [[ ! -f $APACHE_SITE_CONFIG ]]
then
    sudo cp apache_site_entry $APACHE_SITE_CONFIG || critical "Could not copy apache config file to apache sites-available directory"
    sudo /usr/sbin/apache2ctl configtest || critical "Apache config file check failed"
    sudo a2ensite $SITE_NAME || critical "Could not enable $SITE_NAME site"
    sudo a2enmod headers # Needed for some features of the .htaccess provided by the HTML5-boilerplate
    sudo /etc/init.d/apache2 restart || critical "Apache restart failed"
fi
cd "$SITE_CODE_DIR"

info "Fetching submodules"
bash $SITE_CODE_DIR/setup/copy_html5.bash $SITE_CODE_DIR

info "DONE"

#set +x
