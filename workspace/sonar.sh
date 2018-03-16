#!/bin/bash

cd /usr/workspace/clone

echo ">>> sonar scan.."
if [[ -n $SONAR_SOURCES ]]; then
    sonar-scanner -X -Dsonar.sources=$SONAR_SOURCES \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
else
    sonar-scanner -X -Dsonar.sources=/usr/workspace/clone/src \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
fi

cd /usr/workspace