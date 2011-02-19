#!/usr/bin/env python

'''\
Run 'fab --list' to see list of available commands.

References:
# http://docs.fabfile.org/0.9.3/usage/execution.html#how-host-lists-are-constructed
'''

import platform
assert platform.python_version_tuple() > (2,6)

import os
import datetime
import urllib2

from fabric.api import env, roles, local, sudo, run
from fabric import colors
from fabric.utils import puts, warn


SITE_NAME = '{SITE_NAME}'


def _transfer_files(src, dst):
    assert os.getenv('SSH_AUTH_SOCK') is not None # Ensure ssh-agent is running
    if not src.endswith('/'):
        src = src + '/'
    if dst.endswith('/'):
        dst = dst[:-1]
    local('rsync -avh --delete-before --copy-unsafe-links -e ssh {0} {1}'.format(src, dst), capture=False)


@roles('deploy')
def deploy():
    '''Sync code from here to the servers'''
    global env
    global SITE_NAME

    # Two separate calculations because Mac has HOME=/Users/swaroop and
    # Linux has HOME=/home/swaroop and therefore cannot use the same dirname.
    local_dir = os.path.join(os.getenv('HOME'), 'web', SITE_NAME, 'private', SITE_NAME)
    remote_dir = os.path.join('/home', os.getlogin(), 'web', SITE_NAME, 'private', SITE_NAME)
    _transfer_files(local_dir, env.host_string + ':' + remote_dir)
    sudo('apache2ctl graceful')
    try:
        urllib2.urlopen('http://' + env.host_string)
    except urllib2.HTTPError as x:
        warn(colors.red("Failed! Code deployment was a disaster. Apache is throwing {0}.".format(x)))
        showlogs()
        return
    puts(colors.magenta('Success! The {0} server has been updated.'.format(env.host_string)))


def showlogs():
    '''Show logs of the Apache/mod_wsgi server.'''

    def tail_file_if_exists(path):
        sudo('if [[ -f {0} ]]; then tail -20 {0}; fi'.format(path))

    log_dir = os.path.join('/home', os.getlogin(), 'web', SITE_NAME, 'log')
    today = datetime.datetime.today().strftime("%Y%m%d")
    yesterday = (datetime.datetime.today() - datetime.timedelta(days=1)).strftime("%Y%m%d")

    puts(colors.magenta("flask log - today"))
    tail_file_if_exists('{0}/error.{1}.log'.format(log_dir, today))
    puts(colors.magenta("flask log - yesterday"))
    tail_file_if_exists('{0}/error.{1}.log'.format(log_dir, yesterday))

    puts(colors.magenta("apache log"))
    tail_file_if_exists('/var/log/apache2/error.log')


def test():
    '''Run the test suite'''
    local('env TEST=yes python tests.py', capture=False)


def server():
    '''Run the dev server'''
    local('env DEV=yes python runserver.py', capture=False)

