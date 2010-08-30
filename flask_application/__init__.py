#!/usr/bin/env python

from flask import Flask
from flask_application.controllers.frontend import frontend

app = Flask(__name__)
app.register_module(frontend)

