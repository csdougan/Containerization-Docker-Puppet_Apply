#!/bin/bash - 
#===============================================================================
#
#          FILE: setupenv.sh
# 
#         USAGE: ./setupenv.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/07/17 15:08
#      REVISION:  ---
#===============================================================================
set -o nounset                              # Treat unset variables as an error
/pullfromgit.sh
/run_puppet_apply.sh
/bin/bash
