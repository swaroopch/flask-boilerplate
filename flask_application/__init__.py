#!/usr/bin/env python

from flask import Flask
from flask_application.controllers.frontend import frontend

import config

app = Flask(__name__)
app.secret_key = '{SECRET_KEY}'

# http://flask.pocoo.org/docs/patterns/packages/
app.register_module(frontend)

