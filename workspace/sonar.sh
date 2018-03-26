#!/bin/bash

cd /usr/workspace/clone

# Delete Sonar Properties as they Clash with the Pull Request Scan
rm -f sonar-project.properties

if [[ -n $SONAR_MODULES ]]; then
    SONAR_MODULES_PARAM=" -Dsonar.modules=$SONAR_MODULES "
fi

echo ">>> sonar scan.."
if [[ -n $SONAR_SOURCES ]]; then
    sonar-scanner -X -Dsonar.sources=$SONAR_SOURCES $SONAR_MODULES_PARAM \
                    -Dsonar.java.binaries=${SONAR_JAVA_BINARIES} \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
else
    sonar-scanner -X -Dsonar.sources=src $SONAR_MODULES_PARAM \
                    -Dsonar.java.binaries=target \
                    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
                    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"
fi

cd /usr/workspace
