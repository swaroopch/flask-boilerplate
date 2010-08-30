#!/usr/bin/env python

from flask import Flask
from flask_application.controllers.frontend import frontend

import config

log = config.logger(config.SITE_NAME)

app = Flask(__name__)
# http://flask.pocoo.org/docs/patterns/packages/
app.register_module(frontend)

