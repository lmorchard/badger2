from django.conf import settings
from django.conf.urls.defaults import *

from django.views.generic.simple import direct_to_template

from django.contrib import admin
admin.autodiscover()

import badger
badger.autodiscover()

from badger import Progress
from badger_multiplayer.models import Badge, Award, Nomination

from session_csrf import anonymous_csrf_exempt
import django_browserid.views


urlpatterns = patterns('',

    url(r'^$', 'badger.views.home', name='home'),

    (r'', include('examples.urls')),

    (r'^badges/', include('badger_multiplayer.urls')),
    (r'^badges/', include('badger.urls')),
    
    (r'^comments/', include('django.contrib.comments.urls')),

    (r'^accounts/', include('django.contrib.auth.urls')),    
    (r'^accounts/', include('registration.backends.default.urls')),

    (r'^admin/', include(admin.site.urls)),

    #(r'^browserid/', include('django_browserid.urls')),
    # HACK: CSRF troubles wth browserid auth
    url(r'^browserid/verify/', 
        anonymous_csrf_exempt(django_browserid.views.verify),
        name="browserid_verify"),

)

## In DEBUG mode, serve media files through Django.
if settings.DEBUG:
    # Remove leading and trailing slashes so the regex matches.
    media_url = settings.MEDIA_URL.lstrip('/').rstrip('/')
    urlpatterns += patterns('',
        (r'^%s/(?P<path>.*)$' % media_url, 'django.views.static.serve',
         {'document_root': settings.MEDIA_ROOT}),
    )
