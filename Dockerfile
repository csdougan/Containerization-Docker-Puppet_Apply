FROM cdougan/rhel7
 
MAINTAINER craig.dougan@gmail.com

ENV MODULE_URL=""
ENV MODULE_BRANCH=""
ENV PUPPET_MODULE=""
ENV PUPPET_TEST_CASE=""
ENV MODULE_URL=""
ENV SATELLITE_SERVER=ukwkmh-vmui010.wtr.net
ENV PULP_REPO="Waitrose_Puppet_Modules"
ENV MODULE_INSTALL_PATH=/modules
ENV http_proxy=http://wtr-zproprd-hoproxy.johnlewis.co.uk:80
ENV https_proxy=http://wtr-zproprd-hoproxy.johnlewis.co.uk:80
ENV no_proxy=localhost,acceptance.co.uk,wtr.net,johnlewis.co.uk
ENV SMOKE_TEST="false"
 
ADD install_pulp_modules.sh /install_pulp_modules.sh
ADD pullfromgit.sh /pullfromgit.sh
ADD setupenv.sh /setupenv.sh
ADD run_puppet_apply.sh /run_puppet_apply.sh

RUN mkdir -p ${MODULE_INSTALL_PATH} && \
    mkdir -p /tmp/puppet-modules && \
    yum install -y puppet && \
    yum update -y facter && \
    yum update -y hiera && \
    yum install -y rubygems && \
    yum install -y git && \
    yum install -y hostname && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo 'Host *' > /root/.ssh/config && \
    echo '  StrictHostKeyChecking no' >> /root/.ssh/config

ADD id_rsa /root/.ssh/id_rsa
ADD id_rsa.pub /root/.ssh/id_rsa.pub

RUN chmod 600 ~/.ssh/id_rsa && \
    chmod 700 /pullfromgit.sh && \
    chmod 700 /install_pulp_modules.sh && \
    chmod 700 /setupenv.sh && \
    chmod 700 /run_puppet_apply.sh && \
    /install_pulp_modules.sh

ENTRYPOINT ["/setupenv.sh"]
