#!/bin/bash
cd /
if [[ $SMOKE_TEST == "true" ]]; then
  noop="--noop"
else
  noop=""
fi
if [[ ${PUPPET_MODULE} == "" ]]; then
  puppet apply -e 'notify {"you need to specify a module as a parameter":}' --modulepath=${MODULE_INSTALL_PATH}
else
  if [[ ${PUPPET_TEST_CASE} == "" ]]; then
    puppet apply -e "class {'${PUPPET_MODULE}':}" --modulepath=${MODULE_INSTALL_PATH} $noop| tee -a /tmp/puppet_apply_log_${PUPPET_MODULE}.log
  else
    puppet apply /modules/${PUPPET_MODULE}/tests/${PUPPET_TEST_CASE}.pp --modulepath=${MODULE_INSTALL_PATH} $noop| tee -a /tmp/puppet_apply_log_${PUPPET_MODULE}_${PUPPET_TEST_CASE}.log
  fi
fi
