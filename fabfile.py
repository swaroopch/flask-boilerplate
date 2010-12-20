#!/usr/bin/env python

'''\
Run 'fab --list' to see list of available commands.

References:
# http://docs.fabfile.org/0.9.3/usage/execution.html#how-host-lists-are-constructed
'''

import platform
assert platform.python_version_tuple() > (2,6)

import os
import urllib2

from fabric.api import env, roles, local, sudo, run
from fabric import colors
from fabric.utils import puts, warn


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

    # Two separate calculations because Mac has HOME=/Users/swaroop and
    # Linux has HOME=/home/swaroop and therefore cannot use the same dirname.
    local_dir = os.path.join(os.getenv('HOME'), 'web', '{SITE_NAME}', 'private', '{SITE_NAME}')
    remote_dir = os.path.join('/home', os.getlogin(), 'web', '{SITE_NAME}', 'private', '{SITE_NAME}')
    _transfer_files(local_dir, env.host_string + ':' + remote_dir)
    sudo('apache2ctl graceful')
    try:
        urllib2.urlopen('http://' + env.host_string)
    except urllib2.HTTPError as x:
        warn(colors.red("Failed! Code deployment was a disaster. Apache is throwing {0}.".format(x)))
        run('tail /tmp/{0}_error.log'.format('{SITE_NAME}')) # FIXME Error log location should be in /var/log/, etc.
        return
    puts(colors.magenta('Success! The {0} server has been updated.'.format(env.host_string)))


def test():
    '''Run the test suite'''
    local('env TEST=yes python tests.py', capture=False)


def server():
    '''Run the dev server'''
    local('env DEV=yes python runserver.py', capture=False)

