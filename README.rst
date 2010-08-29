Flask Boilerplate Project
=========================

Introduction
------------

I want to be able to quickly whip up websites with all my favorite settings and customizations. So I created this boilerplate project based on the `Flask <http://flask.pocoo.org/>`_ microwebframework.

Why is this useful? Because:

#. Cutting-edge components, good defaults, HTML5 goodness, etc.
#. New Project script - sets up everything for you, including Apache mod_wsgi deployment!

Get Started
-----------

#. Run ``setup/install.sh your.domain.name``
#. That's it. Yes, really.
#. Okay, you *do* have to write your code in `flask_application.py`.

Server
------

Works with Ubuntu Linux, Apache, mod_wsgi.

Currently, the install script assumes that you are already on the target machine w.r.t. both the creation of the git project as well as the deployment.

In the future, we could switch over to deployment via `Fabric <http://fabfile.org/>`_ or even deploy our app in an AppEngine-esque manner using `Silver Lining <http://cloudsilverlining.org/#what-does-it-do>`_.

UI : HTML5 Boilerplate [TODO]
-----------------------------

Use `HTML5 Boilerplate code <http://html5boilerplate.com/>`_ for the UI. This makes the frontend future-ready *and* compatible all the way back to IE6.

Don't forget to `watch the video <http://net.tutsplus.com/tutorials/html-css-techniques/the-official-guide-to-html5-boilerplate/>`_.

API : simpleapi
---------------

Use `simpleapi <http://simpleapi.de/>`_ to write APIs.

I haven't played around much with simpleapi, so I may switch over to something else at a later point.

Other Things to Consider
------------------------

- `Mobile user agent detection <http://pypi.python.org/pypi/mobile.sniffer>`_ to redirect users to a mobile version of the website.

