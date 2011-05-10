#!/usr/bin/env bash

function die
{
    echo "$@"
    exit 1
}

function install_apache_package
{
    name=$1
    shift
    [[ -z "$name" ]] && die "Code Error: Called install_apache_package without a name"

    [[ -z $(dpkg -l | fgrep -i $name) ]] && ( sudo aptitude install $name || die "Could not apt-get $name package" )
}

SITE_CODE_DIR=$PWD

## main ##

# TODO Your code goes here

