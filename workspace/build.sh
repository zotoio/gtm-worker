#!/bin/bash

cd /usr/workspace/clone

if [ -n "$BUILD_COMMAND" ]; then
    echo ">>> running custom build commmand.."
    eval "$BUILD_COMMAND"
else

    case "$BUILD_TYPE" in
            nodejs)
                echo ">>> running node build.."
                npm set strict-ssl false
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

# store dependency bundle if new
if [[ "$S3_DEPENDENCY_BUCKET" != "" ]]; then
    echo "DEPS_FOUND=$DEPS_FOUND"
    if [[ "$DEPS_FOUND" != "true" ]]; then
        echo ">>> packaging dependency bundle: deps-$DEPS_SUM.tar.gz from $DEPS_DIR"
        tar -czf deps-$DEPS_SUM.tar.gz -C "$DEPS_DIR" .
        echo ">>> uploading dependency bundle to s3: deps-$DEPS_SUM.tar.gz"
        https_proxy=$AWS_S3_PROXY aws s3api put-object --bucket $S3_DEPENDENCY_BUCKET --key deps-$DEPS_SUM.tar.gz --body deps-$DEPS_SUM.tar.gz
    fi
fi

cd /usr/workspace/
