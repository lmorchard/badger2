#
# Playdoh puppet magic
#

$PROJ_DIR = "/vagrant"

$DB_NAME = "playdoh"
$DB_USER = "playdoh"
$DB_PASS = "playdoh"

# Get apache up and running
class apache {
    package { "httpd-devel": 
        ensure => present,
        before => File['/etc/httpd/conf.d/playdoh-site.conf']; 
    }
    file { "/etc/httpd/conf.d/playdoh-site.conf":
        source  => "$PROJ_DIR/puppet/files/etc/httpd/conf.d/playdoh-site.conf",
        owner   => "root", group => "root", mode => 0644,
        require => [ Package['httpd-devel'] ];
    }
    service { "httpd":
        ensure    => running,
        enable    => true,
        require   => [
            Package['httpd-devel'],
            File['/etc/httpd/conf.d/playdoh-site.conf']
        ]
        #subscribe => File['/etc/httpd/conf.d/playdoh-site.conf']
    }
}

# Get mysql up and running
class mysql {
    package { "mysql-server": ensure => installed; }
    package { "mysql-devel": ensure => installed; }
    service { "mysqld": 
        ensure => running, 
        enable => true, 
        require => Package['mysql-server']
    }
}

# Install python and compiled modules for project
class python {
    package { 
        [ "python26-devel", "python26-libs", "python26-distribute", "python26-mod_wsgi" ]:
            ensure => installed;
    }
    exec { "pip-install": 
        command => "/usr/bin/easy_install-2.6 -U pip", 
        creates => "/usr/bin/pip",
        require => Package["python26-devel","python26-distribute"]
    }
    exec { "pip-install-compiled":
        command => "/usr/bin/pip install -r $PROJ_DIR/requirements/compiled.txt",
        require => Exec['pip-install']
    }
}

# Various package repo hacks
class repos {

    case $operatingsystem {
        centos: {

            # HACK: In order to speed up destroying and building CentOS boxes,
            # move and retain the yum-cache onto the host side.
            # TODO: IS THIS REALLY A GOOD IDEA?!
            exec { "copy_yum_cache":
                command => "/bin/cp -r /var/cache/yum $PROJ_DIR/yum-cache",
                unless  => "/bin/ls $PROJ_DIR/yum-cache"
            }
            file { "/etc/yum.conf":
                source  => "$PROJ_DIR/puppet/files/etc/yum.conf",
                owner => "root", group => "root",
                require => Exec["copy_yum_cache"]
            }

            # Make sure we've got EPEL for extra packages
            $epel_url = "http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm"
            exec { "repo_epel":
                command => "/bin/rpm -Uvh $epel_url",
                creates => '/etc/yum.repos.d/epel.repo',
                require => File["/etc/yum.conf"]
            }

        }
    }

}

# Install some useful dev tools
class dev_tools {
    package { 
        [ "git", "vim-enhanced" ]:
            ensure => installed;
    }
}

class dev_hacks {
    file { "/vagrant/settings_local.py":
        ensure => file,
        source => "$PROJ_DIR/puppet/files/settings_local.py";
    }
    # HACK: Disable SELinux... causing problems, and I don't understand it.
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

class playdoh_site {
    exec { "create_mysql_database":
        command => "/usr/bin/mysqladmin -uroot create $DB_NAME",
        unless  => "/usr/bin/mysql -uroot -B --skip-column-names -e 'show databases' | /bin/grep '$DB_NAME'",
    }
    exec { "grant_mysql_database":
        command => "/usr/bin/mysql -uroot -B -e'GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY \"$DB_PASS\"'",
        unless  => "/usr/bin/mysql -uroot -B --skip-column-names mysql -e 'select user from user' | /bin/grep '$DB_USER'",
        require => Exec["create_mysql_database"]
    }
    exec { "sql_migrate":
        cwd => "$PROJ_DIR", 
        command => "/usr/bin/python2.6 ./vendor/src/schematic/schematic migrations/",
        require => [
            Service["mysqld"],
            Package["python26-devel", "python26-mod_wsgi" ],
            Exec["grant_mysql_database"]
        ];
    }
    exec { "south_migrate":
        cwd => "$PROJ_DIR", 
        command => "/usr/bin/python2.6 manage.py migrate",
        require => [ Exec["sql_migrate"] ];
    }
}

class dev {

    include repos
    include apache
    include mysql
    include python
    include dev_tools
    include dev_hacks
    include playdoh_site

    Class['repos'] -> 
        Class['mysql'] ->
        Class['python'] -> 
        Class["dev_tools"] -> Class['dev_hacks'] ->  
        Class['apache'] -> 
        Class['playdoh_site']
}

include dev
