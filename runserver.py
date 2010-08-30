#!/usr/bin/env python

from flask_application import app, config

if __name__ == '__main__':
    if config.environment == 'production':
        app.run(host='0.0.0.0')
    else:
        app.run(debug=True)

