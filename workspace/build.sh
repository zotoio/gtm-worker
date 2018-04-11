#!/bin/bash

cd /usr/workspace/clone

if [ -n "$BUILD_COMMAND" ]; then
    echo ">>> running custom build commmand.."
    eval "$BUILD_COMMAND"
else

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
                echo ">>> running node build.."
                npm install && npm run build
                ;;

            maven)
                echo ">>> running maven build.."
                mvn compile
                ;;

            gradle)
                echo ">>> running gradle build.."
                gradle build
                ;;
    esac
fi

cd /usr/workspace/
