#
# Playdoh puppet magic for dev boxes
#
import "classes/*.pp"

$PROJ_DIR = "/vagrant"

$DB_NAME = "playdoh"
$DB_USER = "playdoh"
$DB_PASS = "playdoh"

$USING_SOUTH = 1

class dev {
    # Include all the classes needed for a dev box and establish setup order
    include repos, apache, mysql, python, dev_tools, dev_hacks, playdoh_site
    Class['dev_hacks'] -> Class['repos'] -> Class["dev_tools"] ->  
        Class['mysql'] -> Class['python'] -> Class['apache'] -> 
        Class['playdoh_site']
}

include dev
