Flask Boilerplate Project
=========================

Introduction
------------

I wanted a quick way to create websites with all my favorite settings and customizations. So I created this boilerplate project based on the `Flask <http://flask.pocoo.org/>`_ microwebframework.

Why is this useful? Because:

#. Cutting-edge components, good defaults, HTML5 goodness, etc.
#. New Project script - sets up everything for you, including Apache mod_wsgi deployment!

Get Started
-----------

#. Run ``bash setup/install.bash your.domain.name``
#. That's it. Yes, really.
#. Okay, you *do* have to write your code in `flask_application/controllers/frontend.py`.
#. And when you edit your code, use `fab deploy` to upload the latest code to a server.

Modular
-------

By default, it uses `packages and modules <http://flask.pocoo.org/docs/patterns/packages/>`_ to make it very simple to split up the controllers (and models) into logical groups in separate files, rather than using a monolithic file which contains everything.

Server
------

The installation script works specifically with Ubuntu Linux, Apache, mod_wsgi only.

Currently, the install script assumes that you are already on the target machine w.r.t. both the creation of the git project as well as the deployment.

We are using `Fabric <http://fabfile.org/>`_ to deploy new code to the server.

In the future, we may even deploy our app in an AppEngine-esque manner using `Silver Lining <http://cloudsilverlining.org/#what-does-it-do>`_.

UI : HTML5 Boilerplate + 960 Grid System
----------------------------------------

It uses `HTML5 Boilerplate code <http://html5boilerplate.com/>`_ for the UI. This makes the frontend future-ready *and* compatible all the way back to IE6. Don't forget to `watch the video <http://net.tutsplus.com/tutorials/html-css-techniques/the-official-guide-to-html5-boilerplate/>`_.

It uses `960 Grid System <http://960.gs/>`_ for the layout of your pages.

Other Things to Consider
------------------------

- API wrapper like `simpleapi <http://simpleapi.de/>`_
- `Mobile user agent detection <http://pypi.python.org/pypi/mobile.sniffer>`_ to redirect users to a mobile version of the website.

