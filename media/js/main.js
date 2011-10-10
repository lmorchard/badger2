/**
 *
 */
$(document).ready(function () {

    $('.browserid-signin').click(function (ev) {
        e.preventDefault();
        navigator.getVerifiedEmail(function(assertion) {
            if (assertion) {
                var $e = $('#id_assertion');
                $e.val(assertion.toString());
                $e.parent().submit();
            }
        });
    });

});
