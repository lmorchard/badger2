from django.conf import settings
from django.db import models
from django.db.models.signals import post_save
from django.contrib.auth.models import User
from django.dispatch import receiver

try:
    from commons.urlresolvers import reverse
except ImportError, e:
    from django.core.urlresolvers import reverse

try:
    from tower import ugettext_lazy as _
except ImportError, e:
    from django.utils.translation import ugettext_lazy as _


MAX_USERNAME_CHANGES = getattr(settings, 'PROFILE_MAX_USERNAME_CHANGES', 3)


class UserProfile(models.Model):

    user = models.ForeignKey(User, unique=True)

    username_changes = models.IntegerField(default=0)

    is_confirmed = models.BooleanField(default=False)

    display_name = models.CharField(max_length=64, blank=True, null=True,
                                    unique=False)

    bio = models.TextField(blank=True)
    organization = models.CharField(max_length=255, default='', blank=True)
    location = models.CharField(max_length=255, default='', blank=True)
    
    created = models.DateTimeField(auto_now_add=True, blank=False)
    modified = models.DateTimeField(auto_now=True, blank=False)

    class Meta:
        pass

    def __unicode__(self):
        return (self.display_name and 
                self.display_name or self.user.username)

    def get_absolute_url(self):
        return reverse('profiles.views.profile_view', 
                       kwargs={'username':self.user.username})

    def allows_edit(self, user):
        if user == self.user:
            return True
        if user.is_staff or user.is_superuser:
            return True
        return False

    def username_changes_remaining(self):
        return MAX_USERNAME_CHANGES - self.username_changes

    def can_change_username(self, user=None):
        if self.username_changes_remaining() > 0:
            return True
        return False

    def change_username(self, username, user=None):
        if not self.can_change_username(user):
            return False
        if username != self.user.username:
            self.user.username = username
            self.user.save()
            self.username_changes += 1
            self.save()
        return True


def autocreate_user_profile(self):
    """Ensure user profile exists when accessed"""
    profile, created = UserProfile.objects.get_or_create(
        user=User.objects.get(id=self.id), 
        defaults=dict())
    return profile


# HACK: monkeypatch User.get_profile to ensure the profile exists
User.get_profile = autocreate_user_profile

# HACK: monkeypatch User.__unicode__ to use profile display_name when available
def user_display_name(self):
    return unicode(self.get_profile())
User.__unicode__ = user_display_name

# HACK: monkeypatch User.get_absolute_url() to return profile URL
def user_get_absolute_url(self):
    return self.get_profile().get_absolute_url()
User.get_absolute_url = user_get_absolute_url
