from django.conf import settings
from django.conf.urls.defaults import *

from django.views.generic.simple import direct_to_template

from django.contrib import admin
admin.autodiscover()

import badger
badger.autodiscover()

from badger import Progress
from badger_multiplayer.models import Badge, Award, Nomination

urlpatterns = patterns('',

    url(r'^$', direct_to_template, dict(
        template='home.html',
        extra_context=dict(
            badge_list=Badge.objects.order_by('-modified').all()[:9],
            award_list=Award.objects.order_by('-modified').all()[:9],
        )
    ), name='home'),

    (r'', include('examples.urls')),

    (r'^badges/', include('badger_multiplayer.urls')),
    (r'^badges/', include('badger.urls')),
    
    (r'^comments/', include('django.contrib.comments.urls')),

    (r'^accounts/', include('django.contrib.auth.urls')),
    (r'^accounts/', include('registration.backends.default.urls')),

    (r'^admin/doc/', include('django.contrib.admindocs.urls')),
    (r'^admin/', include(admin.site.urls)),

    (r'^browserid/', include('django_browserid.urls')),

)

## In DEBUG mode, serve media files through Django.
if settings.DEBUG:
    # Remove leading and trailing slashes so the regex matches.
    media_url = settings.MEDIA_URL.lstrip('/').rstrip('/')
    urlpatterns += patterns('',
        (r'^%s/(?P<path>.*)$' % media_url, 'django.views.static.serve',
         {'document_root': settings.MEDIA_ROOT}),
    )
