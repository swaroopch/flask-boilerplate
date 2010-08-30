#!/usr/bin/env python

from flask import request, render_template
from flask_application import app, log, config

import datetime

@app.route('/')
def index():
    log.debug('rendering index')
    return render_template(
                'index.html',
                config=config,
                now=datetime.datetime.now,
            )

