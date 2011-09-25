/**
 *
 */
$(document).ready(function () {

    $('.browserid-signin').click(function (ev) {
        navigator.id.getVerifiedEmail(function(assertion) {
            if (assertion) {
                // This code will be invoked once the user has successfully
                // selected an email address they control to sign in with.
            } else {
                // something went wrong!  the user isn't logged in.
            }
        });
    });
    

});
