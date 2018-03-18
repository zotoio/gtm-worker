#!/bin/bash

cd /usr/workspace/clone

echo ">>> sonar scan.."
if [[ -n $SONAR_SOURCES ]]; then
    sonar-scanner -X -Dsonar.sources=$SONAR_SOURCES \
                    -Dsonar.modules=${SONAR_MODULES} \
                    -Dsonar.binaries=${SONAR_BINARIES} \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
else
    sonar-scanner -X -Dsonar.sources=src \
                    -Dsonar.binaries=target \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
fi

cd /usr/workspace