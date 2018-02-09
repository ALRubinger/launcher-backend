#!/usr/bin/env bash

. inherit-env

yum -y update
yum -y install centos-release-scl java-1.8.0-openjdk-devel git
yum -y install rh-maven33

export LAUNCHER_MISSIONCONTROL_OPENSHIFT_API_URL=https://dev.rdu2c.fabric8.io:8443
export LAUNCHER_MISSIONCONTROL_OPENSHIFT_CONSOLE_URL=https://dev.rdu2c.fabric8.io:8443
#export LAUNCHER_MISSIONCONTROL_OPENSHIFT_CLUSTERS_FILE=<path to an openshift-clusters.yaml file>

export LAUNCHER_KEYCLOAK_URL=https://sso.openshift.io/auth
export LAUNCHER_KEYCLOAK_REALM=rh-developers-launch
export LAUNCHER_BOOSTER_CATALOG_REPOSITORY=https://github.com/fabric8-launcher/launcher-booster-catalog.git
export LAUNCHER_BOOSTER_CATALOG_REF=master
export LAUNCHER_TESTS_TRUSTSTORE_PATH=${PWD}/services/git-service-impl/src/test/resources/hoverfly/hoverfly.jks
export LAUNCHER_PREFETCH_BOOSTERS=false

# OSIO env vars
export WIT_URL=https://api.prod-preview.openshift.io
export AUTH_URL=https://auth.prod-preview.openshift.io
export KEYCLOAK_SAAS_URL=https://sso.prod-preview.openshift.io/
export OPENSHIFT_API_URL=https://f8osoproxy-test-dsaas-preview.b6ff.rh-idev.openshiftapps.com

#This will be replaced by the Jenkins slaves
export LAUNCHER_MISSIONCONTROL_OPENSHIFT_TOKEN=TEMP_TOKEN
export LAUNCHER_MISSIONCONTROL_GITHUB_USERNAME=hoverfly
export LAUNCHER_MISSIONCONTROL_GITHUB_TOKEN=hoverfly
export LAUNCHER_MISSIONCONTROL_GITLAB_USERNAME=hoverfly
export LAUNCHER_MISSIONCONTROL_GITLAB_PRIVATE_TOKEN=hoverfly
export LAUNCHER_MISSIONCONTROL_BITBUCKET_USERNAME=hoverfly
export LAUNCHER_MISSIONCONTROL_BITBUCKET_APPLICATION_PASSWORD=hoverfly

# Source environment variables of the jenkins slave
# that might interest this worker.
if [ -e "../jenkins-env" ]; then
  cat ../jenkins-env \
    | grep -E "(LAUNCHER_MISSIONCONTROL_OPENSHIFT_TOKEN|LAUNCHER_MISSIONCONTROL_GITHUB_USERNAME|LAUNCHER_MISSIONCONTROL_GITHUB_TOKEN|LAUNCHER_MISSIONCONTROL_GITLAB_USERNAME|LAUNCHER_MISSIONCONTROL_GITLAB_TOKEN)=" \
    | sed 's/^/export /g' \
    > /tmp/jenkins-env
  source /tmp/jenkins-env
fi

scl enable rh-maven33 'mvn install failsafe:integration-test failsafe:verify -Pit'

if [ $? -ne 0 ]; then
    echo 'Build Failed!'
    exit 1
fi
