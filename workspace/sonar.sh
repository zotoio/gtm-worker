#!/bin/bash

cd /usr/workspace/clone

if [[ -z "$SONAR_SOURCES" ]]; then
    SONAR_SOURCES='src/main'
fi

if [[ -z "$SONAR_JAVA_BINARIES" ]]; then
    if [[ -f 'pom.xml' ]]; then
        SONAR_JAVA_BINARIES='target/classes'
    fi
    if [[ -f 'build.gradle' ]]; then
        SONAR_JAVA_BINARIES='build/classes'
    fi
fi

# if a bundle dir exists, assume aem structure
if [[ -d 'bundle' ]]; then
    if [[ ! $SONAR_MODULES ]]; then
        SONAR_MODULES='bundle'
    fi
fi

if [[ -z "$SONAR_EXCLUSIONS" ]]; then
    SONAR_EXCLUSIONS='src/test/**/*'
fi

# if a root src dir exists, assume no modules subdirs

if [[ ! "$SONAR_KEEP_PROJECT_PROPERTIES" = "true" ]]; then
    # Delete Sonar Properties as they Clash with the Pull Request Scan
    rm -f sonar-project.properties
    echo sonar.sources=$SONAR_SOURCES >> sonar-project.properties
    echo sonar.tests=$SONAR_TESTS >> sonar-project.properties
    echo sonar.java.binaries=$SONAR_JAVA_BINARIES >> sonar-project.properties
    echo sonar.exclusions=$SONAR_EXCLUSIONS >> sonar-project.properties
    echo sonar.modules=$SONAR_MODULES >> sonar-project.properties
    echo sonar.language=$SONAR_LANGUAGE >> sonar-project.properties
fi

echo ">>> sonar scan.."
sonar-scanner -X \
    -Dsonar.projectKey=${SONAR_GITHUB_REPOSITORY/\//-} \
    -Dsonar.projectName="$SONAR_PROJECTNAME_PREFIX${SONAR_GITHUB_REPOSITORY/\// :: }"

cd /usr/workspace
