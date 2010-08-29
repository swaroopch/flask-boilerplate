#!/usr/bin/env python
# coding=utf-8

import sys
assert (2,6) <= sys.version_info < (3,0)

import datetime

import config
log = config.logger(config.SITE_NAME)

from flask import Flask, request, render_template
app = Flask(__name__)

app.secret_key = '{SECRET_KEY}'

@app.route('/')
def index():
    log.debug('rendering index')
    return render_template(
                'index.html',
                title="Welcome to {0}".format(config.SITE_NAME),
                now=datetime.datetime.now,
            )

if __name__ == '__main__':
    if config.environment == 'production':
        app.run(host='0.0.0.0')
    else:
        app.run(debug=True)

