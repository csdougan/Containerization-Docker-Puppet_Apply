#!/bin/bash - 
#===============================================================================
#
#          FILE: pullfromgit.sh
# 
#         USAGE: ./pullfromgit.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 13/07/17 08:48
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
if [[ $MODULE_URL != "" ]]; then
 git clone ${MODULE_URL} /tmp/puppet-modules/${PUPPET_MODULE} 
    cd /tmp/puppet-modules/${PUPPET_MODULE}
    [[ $MODULE_BRANCH != "" ]] && git checkout -t origin/${MODULE_BRANCH}
    module_filename=$(puppet module build /tmp/puppet-modules/${PUPPET_MODULE}|tail -n1 | awk '{print $NF}')
    if [[ $module_filename == "" ]]; then
      exit 1
    fi
    puppet module install ${module_filename} --ignore-dependencies --modulepath=${MODULE_INSTALL_PATH}
fi
