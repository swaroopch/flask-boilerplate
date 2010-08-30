#!/usr/bin/env python
# coding=utf-8

import sys
assert (2,6) <= sys.version_info < (3,0)

import datetime
from flask import Flask
import config

app = Flask(__name__)
app.secret_key = '{SECRET_KEY}'

log = config.logger(config.SITE_NAME)

import flask_application.views

