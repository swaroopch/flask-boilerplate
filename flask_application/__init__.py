#!/usr/bin/env python

import os

# Logging
import logging
logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s] [%(name)s] [%(levelname)s] %(message)s',
    datefmt='%Y%m%d-%H:%M%p',
)

# Flask
from flask import Flask
app = Flask(__name__)

# Config
if os.getenv('DEV') == 'yes':
    app.config.from_object('flask_application.config.DevelopmentConfig')
    app.logger.info("Config: Development")
elif os.getenv('TEST') == 'yes':
    app.config.from_object('flask_application.config.TestConfig')
    app.logger.info("Config: Test")
else:
    app.config.from_object('flask_application.config.ProductionConfig')
    app.logger.info("Config: Production")

# Helpers
from flask_application.helpers import datetimeformat
app.jinja_env.filters['datetimeformat'] = datetimeformat

# http://flask.pocoo.org/docs/patterns/packages/
from flask_application.controllers.frontend import frontend
app.register_module(frontend)

