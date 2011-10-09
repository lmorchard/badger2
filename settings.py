# This is your project's main settings file that can be committed to your
# repo. If you need to override a setting locally, use settings_local.py

from funfactory.settings_base import *

# Make this unique, and don't share it with anybody.
SECRET_KEY = '1iz#v0m55@h26^m6hxk3a7at*h$qj_2a$juu1#nv50548j(x1v'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'jingo.Loader',
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
)

JINGO_EXCLUDE_APPS = (
    "admin", "debug_toolbar", "comments",
)

# Bundles is a dictionary of two dictionaries, css and js, which list css files
# and js files that can be bundled together by the minify app.
MINIFY_BUNDLES = {
    'css': {
        'main': (
            'css/normalize.css',
            'css/main.css',
        ),
        'example_css': (
            'css/examples/main.css',
        ),
    },
    'js': {
        'main': (
            'js/libs/jquery-1.4.4.min.js',
            'js/main.js',
        ),
        'example_js': (
            'js/libs/jquery-1.4.4.min.js',
        ),
    }
}

INSTALLED_APPS = INSTALLED_APPS + (
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.admin',
    'django.contrib.admindocs',

    'examples',

    "profiles",
    "registration",

    "badger_multiplayer",
    "badger",

    # migrations
    'south',
)
