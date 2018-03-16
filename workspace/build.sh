#!/bin/bash

cd /usr/workspace/clone

if [ -n "$BUILD_COMMAND" ]; then
    echo ">>> running custom build commmand.."
    exec "$BUILD_COMMAND"
else
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