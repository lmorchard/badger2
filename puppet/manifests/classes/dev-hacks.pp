# Ensure some handy dev tools are available.
class dev_tools {
    package { 
        [ "git", "vim-enhanced" ]:
            ensure => installed;
    }
}

# Do some dirty, dirty things to make development nicer.
class dev_hacks {

    file { "/vagrant/settings_local.py":
        ensure => file,
        source => "$PROJ_DIR/puppet/files/settings_local.py";
    }

    case $operatingsystem {

        centos: {

            # TODO: IS THIS REALLY A GOOD IDEA?!
            # In order to speed up destroying and building CentOS boxes,
            # move and retain the yum-cache onto the host side.
            exec { "copy_yum_cache":
                command => "/bin/cp -r /var/cache/yum $PROJ_DIR/yum-cache",
                unless  => "/bin/ls $PROJ_DIR/yum-cache"
            }
            file { "/etc/yum.conf":
                source  => "$PROJ_DIR/puppet/files/etc/yum.conf",
                owner => "root", group => "root",
                require => Exec["copy_yum_cache"]
            }

            # Disable SELinux... causing problems, and I don't understand it.
            # TODO: see http://blog.endpoint.com/2010/02/selinux-httpd-modwsgi-26-rhel-centos-5.html
            file { "/etc/selinux/config":
                source => "/vagrant/puppet/files/etc/selinux/config",
                owner => "root", group => "root", mode => 0644;
            }
            exec { "disable_selinux_enforcement":
                command => "/usr/sbin/setenforce 0",
                unless => "/usr/sbin/getenforce | grep -q 'Disabled'";
            }

        }

    }

}
