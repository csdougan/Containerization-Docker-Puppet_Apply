node {
  def moduleName='provision_websphere_as'
  def module_branch='master'
  def dockerHost='1.1.0.3'
  def dockerPort='1234'
  def containerName='centos_test'
  def dockerImage='cdougan/centos_testing'
  def gitCredentialID='bitbucket.org'
  def gitURL='https://cdougan@bitbucket.org/blainethemono'
  def nexus_repository="Puppet-Modules"
  def pipeline_workspace=pwd()
  def git_module_dir=moduleName + '-' + module_branch
  def module_package = 'tgz'
  def module_extension = 'tar.gz'
  def rpm_package = 'rpm'
  def rpm_extension = 'rpm'
  def nexus_url = 'http://abc-watm-artefactrepo.somedomain.com:8081'

    docker.withServer("tcp://${dockerHost}:${dockerPort}", "${containerName}") {
      docker.image("${dockerImage}").inside {
        stage('Clean Workspace') {
          sh """#!/bin/bash
          rm -rf *
          """
        }
        stage('Checkout Pipeline Stages Code') {
          checkout(
            [$class: 'GitSCM', 
              branches: [[name: '*/master']], 
              doGenerateSubmoduleConfigurations: false, 
              extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "stages"]], 
              submoduleCfg: [], 
              userRemoteConfigs: [[credentialsId: "${gitCredentialID}", url: "${gitURL}/pipeline_stages_library.git"]]
            ]
          )
          sh """#!/bin/bash
          cd stages
          git config --global user.email "jenkins@indocker.com"
          git config --global user.name "Jenkins in Docker"
          """
        }
        stage('Checkout Puppet Code') {
          checkout(
            [$class: 'GitSCM', 
              branches: [[name: '*/master']], 
              doGenerateSubmoduleConfigurations: false, 
              extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: "${git_module_dir}"]], 
              submoduleCfg: [], 
              userRemoteConfigs: [[credentialsId: "${gitCredentialID}", url: "${gitURL}/${moduleName}.git"]]
            ]
          )
        }
        stage('Puppet Parser Validate') {
          sh """#!/bin/bash
          ls -ld ${git_module_dir}
          echo 'sourcing bash profile'
          source ~/.bash_profile
          echo 'puppet parser validate'
          find ${git_module_dir} -name '*.pp' | xargs puppet parser validate
          echo 'finished puppet parser validate'
          """
        }
        stage('Rake spec test') {
          sh """#!/bin/bash
          source ~/.bash_profile
          cd ${git_module_dir}
          rake spec_clean
          rm -rf spec/fixtures/modules/*
          rake spec
          """
       }
       stage('Puppet Lint tests') {
         sh """#!/bin/bash
         source ~/.bash_profile
         cd ${git_module_dir}
         rake lint
         """
       }
       stage('Puppet Apply Smoke Test') {
         sh """#!/bin/bash
         source ~/.bash_profile
         cd ${git_module_dir}
         rake spec_prep
         puppet apply --noop --modulepath=./spec/fixtures/modules -e "class{'${moduleName}':}"
         rake spec_clean
         echo "Pipeline Workspace [rake] :  ${pipeline_workspace}"
         """
       }
       stage ('Build Module') {
         sh """#!/bin/bash
         source ~/.bash_profile
set -x
         cat ${git_module_dir}/metadata.json | python -c "import sys,json; print json.load(sys.stdin)['name']" > ${pipeline_workspace}/full_module_name.txt
         cat ${pipeline_workspace}/full_module_name.txt | awk -F- '{print \$1}'  > ${pipeline_workspace}/module_author.txt
         cat ${git_module_dir}/metadata.json | python -c "import sys,json; print json.load(sys.stdin)['version']"  > ${pipeline_workspace}/module_version.txt
         """
         env.full_module_name=readFile("${pipeline_workspace}/full_module_name.txt").trim()
         env.module_author=readFile("${pipeline_workspace}/module_author.txt").trim()
         env.module_version=readFile("${pipeline_workspace}/module_version.txt").trim()
        sh """#!/bin/bash
        source ~/.bash_profile
        cd ${git_module_dir}
        if [[ \$(git describe --tags 2>/dev/null) != "${module_version}" ]]; then
          git tag -a "${module_version}-${module_branch}" -m "Version ${module_version}";
        fi
        git_num_of_commits=\$(git describe --tags --long| cut -d- -f3)
        git_hash=\$(git describe --tags --long| cut -d- -f4)
        if [[ $module_branch == "master" ]]; then
          release_version=1
        else
          release_version="git.${module_branch}.\${git_num_of_commits}.\${git_hash}"
        fi
        echo "\${release_version}" > ${pipeline_workspace}/release_version.txt
        cd "${pipeline_workspace}"
        puppet module build ${git_module_dir}
        """
        env.release_version = readFile("${pipeline_workspace}/release_version.txt").trim()
        env.compiled_file = pipeline_workspace + '/' + git_module_dir + '/pkg/' + full_module_name + '-' + module_version + '.' + module_extension
      }
      stage ('Build RPM') {
        sh """#!/bin/bash
        	cd ${pipeline_workspace}
       		echo "pipeline_workspace : ${pipeline_workspace}"
		cat <<- EOF > ${pipeline_workspace}/.rpmmacros
			%_topdir       ${pipeline_workspace}/rpm
			%_tmppath      ${pipeline_workspace}/rpm/tmp
		EOF
        	mkdir -p  ${pipeline_workspace}/rpm ${pipeline_workspace}/rpm/BUILD ${pipeline_workspace}/rpm/RPMS ${pipeline_workspace}/rpm/RPMS/noarch ${pipeline_workspace}/rpm/SOURCES ${pipeline_workspace}/rpm/SPECS ${pipeline_workspace}/rpm/SRPM ${pipeline_workspace}/rpm/tmp
          	INSTALL_DIR="/opt/puppet-modules"
          	MODULE_FILE=\$(basename "${compiled_file}")
          	echo "Module File : \${MODULE_FILE}"
          MODULE_DIR=\$(echo "\${MODULE_FILE}" | sed 's/.tar.*//g')
          echo "Module_dir : \${MODULE_DIR}"
          cp ${compiled_file} ${pipeline_workspace}/rpm/SOURCES/
          DESCRIPTION=\$(grep summary "\${git_module_dir}/metadata.json" | awk -F: '{print \$2}' | sed 's/,\$//g')
          RPM_PREFIX="puppet_module_${full_module_name}"
          cat <<- EOF > "${pipeline_workspace}/rpm/SPECS/puppet-module-\${RPM_PREFIX}-${module_version}-${release_version}.spec"
		Summary: Locally installs \${RPM_PREFIX} to be used with puppet apply
		Name: \${RPM_PREFIX}
		Version: ${module_version}
		License: Restricted
		Release: ${release_version}
		BuildRoot: %{_builddir}/%{name}-root
		Packager: ${module_author}
		Prefix: \${INSTALL_DIR}
		BuildArchitectures: noarch
		Source1: \${MODULE_FILE}
		%description
		\${DESCRIPTION}
		%prep
		%build
		pwd
		cd %{_sourcedir}
		%install
		pwd
		echo \"Removing RPM Build Root : \\\${RPM_BUILD_ROOT}\"
		rm -rf \\\${RPM_BUILD_ROOT}
		mkdir -p \\\${RPM_BUILD_ROOT}\${INSTALL_DIR}
		tar zxvf %{SOURCE1} --directory=\\\${RPM_BUILD_ROOT}\${INSTALL_DIR}
		mv \\\${RPM_BUILD_ROOT}\${INSTALL_DIR}/\${MODULE_DIR} \\\${RPM_BUILD_ROOT}\${INSTALL_DIR}/${moduleName}
		%clean
		rm -rf \\\${RPM_BUILD_ROOT}
		%files
		%defattr(-,puppet,puppet)
	EOF
	echo "\${INSTALL_DIR}/${moduleName}/" >> "${pipeline_workspace}/rpm/SPECS/puppet-module-\${RPM_PREFIX}-${module_version}-${release_version}.spec"
        rpmbuild --define "_topdir ${pipeline_workspace}/rpm" --define "_tmppath ${pipeline_workspace}/rpm/tmp" -ba "${pipeline_workspace}/rpm/SPECS/puppet-module-\${RPM_PREFIX}-${module_version}-${release_version}.spec"
	built_rpm=${pipeline_workspace}/rpm/RPMS/noarch/\${RPM_PREFIX}-${module_version}-${release_version}.noarch.rpm
        """ 
      }
    }
  }
}
