#!/bin/bash

cd /usr/workspace

echo ">>> sonar scan.."
if [[ -n $SONAR_SOURCES ]]; then
    sonar-scanner -Dsonar.sources=$SONAR_SOURCES \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
else
    sonar-scanner -Dsonar.sources=/usr/workspace/clone/src \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
fi