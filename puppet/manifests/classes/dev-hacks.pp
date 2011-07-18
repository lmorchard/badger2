# Do some dirty, dirty things to make development nicer.
class dev_hacks {

    file { "$PROJ_DIR/settings_local.py":
        ensure => file,
        source => "$PROJ_DIR/puppet/files/settings_local.py";
    }

    file { "/home/vagrant/logs":
        ensure => directory,
        owner => "vagrant", group => "vagrant", mode => 0755
    }

    case $operatingsystem {

        centos: {

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

# Ensure some handy dev tools are available.
class dev_tools {
    package { 
        [ "git", "subversion-devel", "vim-enhanced", "man", "man-pages",
            "nfs-utils", "nfs-utils-lib", "telnet", "nc" ]:
            ensure => installed;
    }
}

