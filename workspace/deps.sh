#!/bin/bash

# Check Dependencies for Build

cd /usr/workspace/clone

if [[ -z "$BUILD_TYPE" ]]; then
    if [[ -f 'pom.xml' ]]; then
        BUILD_TYPE='maven'
    fi
    if [[ -f 'build.gradle' ]]; then
        BUILD_TYPE='gradle'
    fi
fi

case "$BUILD_TYPE" in
        nodejs)
            echo ">>> Checking for package.json..."
            if [ ! -f ./package.json ]; then
                echo ">>> No File: package.json"
                exit 1; fi
            ;;

        maven)
            echo ">>> Checking for pom.xml..."
            if [ ! -f ./pom.xml ]; then 
                echo ">>> No File: pom.xml"
                exit 1; fi
            ;;

        gradle)
            echo ">>> Checking for build.gradle..."
            if [ ! -f ./build.gradle ]; then 
                echo ">>> No File: build.gradle"
                exit 1; fi
            ;;
esac

cd /usr/workspace/
