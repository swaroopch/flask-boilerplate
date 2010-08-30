#!/usr/bin/env python

## Imports ##

import os
import logging
import random

## Functionality ##

logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s][%(levelname)s] %(message)s',
    datefmt='%Y%m%d-%H:%M%p',
)

def logger(name):
    return logging.getLogger(name)

def is_dev_env():
    global environment
    return environment == 'development'

## The actual configuration ##

SITE_NAME = '{SITE_NAME}'

# You must change these for your specific deployment:
environment = 'development'

