#!/usr/bin/env python

'''\
Run 'fab --list' to see list of available commands.

References:
# http://docs.fabfile.org/0.9.3/usage/execution.html#how-host-lists-are-constructed
'''

import os
import platform

from fabric.api import hosts, local, sudo
from fabric import colors

def _transfer_files(src, dst):
    assert os.getenv('SSH_AUTH_SOCK') is not None # Ensure ssh-agent is running
    assert src.endswith('/')
    assert not dst.endswith('/')
    local('rsync -avh --delete-before --copy-unsafe-links -e ssh {0} {1}'.format(src, dst), capture=False)


## TODO This is only an example. Change this according to your specific servers setup.
@hosts('domain.com')
def deploy():
    '''Deploys the code from the laptop to the server'''
    assert platform.system() == 'Darwin' # Ensures that I run this only on the laptop (Darwin == Mac OS X)
    local_dir = '/Users/swaroop/code/domain.com/'
    remote_dir = 'domain.com:/home/swaroop/web/domain.com/private/domain.com'
    _transfer_files(local_dir, remote_dir)
    sudo('apache2ctl graceful')
    print(colors.magenta('Success! The server has been updated.'))


def test():
    '''Run the test suite'''
    local('env TEST=yes python tests.py', capture=False)


def server():
    '''Run the dev server'''
    local('env DEV=yes python runserver.py', capture=False)


