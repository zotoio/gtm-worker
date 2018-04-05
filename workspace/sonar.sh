#!/bin/bash

cd /usr/workspace/clone

if [[ ! $SONAR_KEEP_PROJECT_PROPERTIES = 'true' ]]; then
    # Delete Sonar Properties as they Clash with the Pull Request Scan
    rm -f sonar-project.properties
fi

if [[ -n $SONAR_MODULES ]]; then
    if [[ ! -d "$SONAR_MODULES" ]]; then
        echo ">>> No Modules Directory. Exiting..."
        exit 1;
    fi
    SONAR_MODULES_PARAM=" -Dsonar.modules=$SONAR_MODULES "
fi

# Test for Binaries and Sources Directories
#if [[ ! -d "$SONAR_JAVA_BINARIES" ]]; then
#    echo ">>> No Binaries Directory. Exiting..."
#    exit 1;
#el
if [[ ! -d "$SONAR_MODULES/$SONAR_SOURCES" ]]; then
    echo ">>> No Sources Directory. Exiting..."
    exit 1;
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
