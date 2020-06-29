#!/bin/bash - 
#===============================================================================
#
#          FILE: list_all_satellite.modules.sh
# 
#         USAGE: ./list_all_satellite.modules.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/07/17 11:19
#      REVISION:  ---
#===============================================================================
if [[ $SATELLITE_SERVER == "" ]]; then
  SATELLITE_SERVER=ukwkmh-vmui010.wtr.net
fi
if [[ $MODULE_INSTALL_PATH == "" ]]; then
  MODULE_INSTALL_PATH="/modules"
fi
mkdir -p $MODULE_INSTALL_PATH
mkdir -p /tmp/puppet-modules
PULP_BASE_URL="http://${SATELLITE_SERVER}/pulp/puppet/"
curl $PULP_BASE_URL 2>/dev/null|grep '\[DIR\]'|awk -F\" '{print $8}'|while read PULP_REPO; do
  PULP_URL="${PULP_BASE_URL}${PULP_REPO}system/releases/"
  curl $PULP_URL 2> /dev/null|awk -F\" '{if (NF == 13) print $8}'| while read line; do
    curl "${PULP_URL}${line}" 2>/dev/null|grep "\[DIR\]"|awk -F\" '{print $8}'|while read author; do
      curl "${PULP_URL}${line}${author}" 2>/dev/null|grep "tar\.gz"|awk -F\" '{print $8}'|awk -F- '{print $2}'|sort |uniq|while read modulename; do
      module_filename=$(curl "${PULP_URL}${line}/${author}" 2>/dev/null|grep "tar\.gz"|awk -F\" '{print $8}'|grep $(echo $author|sed 's/\///g')-${modulename} |tail -n1)
      wget "${PULP_URL}${line}${author}${module_filename}" 2>/dev/null -O /tmp/puppet-modules/${module_filename}
      puppet module install /tmp/puppet-modules/${module_filename} --ignore-dependencies --modulepath=${MODULE_INSTALL_PATH}
      done
    done
  done
done
