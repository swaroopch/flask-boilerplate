#!/usr/bin/env python

from fabric.api import env, local, put, run, sudo
from fabric import colors

# NOTE Add host names here so that you do not have to specify it every time on the command line
# See http://docs.fabfile.org/usage/execution.html#how-host-lists-are-constructed
# example: env.hosts.extend(['user@server1:port', 'user@server2:port']) # where port is the SSH port
env.hosts.extend([])

SITE_NAME = '{SITE_NAME}'

def deploy():
    global SITE_NAME

    # Zip current directory
    local('rm -f /tmp/{0}.zip'.format(SITE_NAME))
    local('zip -rq /tmp/{0}.zip .'.format(SITE_NAME))
    # Copy to server
    run('rm -f /tmp/{0}.zip'.format(SITE_NAME))
    put('/tmp/{0}.zip'.format(SITE_NAME), '/tmp/')
    run('mkdir -p $HOME/web/{0}'.format(SITE_NAME))
    run('cd $HOME/web/{0} && unzip /tmp/{0}.zip'.format(SITE_NAME))
    # Cleanup
    run('rm -f /tmp/{0}.zip'.format(SITE_NAME))
    local('rm -f /tmp/{0}.zip'.format(SITE_NAME))
    # Restart server
    sudo('apache2ctl restart')
    print(colors.magenta('Success! The website code has been updated.'))

