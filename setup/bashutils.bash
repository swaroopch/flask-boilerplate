
## Color ##

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

