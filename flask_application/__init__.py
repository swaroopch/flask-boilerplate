#!/usr/bin/env python

from flask import Flask

app = Flask(__name__)
app.secret_key = '{SECRET_KEY}'

# http://flask.pocoo.org/docs/patterns/packages/
from flask_application.controllers.frontend import frontend
app.register_module(frontend)

