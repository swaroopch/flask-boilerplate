#!/usr/bin/env python

from flask import Module, request, render_template
from flask_application import config

import datetime

log = config.logger(__name__)
frontend = Module(__name__)

@frontend.route('/')
def index():
    log.debug('rendering index')
    return render_template(
                'index.html',
                config=config,
                now=datetime.datetime.now,
            )

