#!/bin/bash

# Check Dependencies for Build

cd /usr/workspace/clone

if [[ -z "$BUILD_TYPE" ]]; then
    if [[ -f 'package.json' ]]; then
        BUILD_TYPE='nodejs'
    fi
    if [[ -f 'pom.xml' ]]; then
        BUILD_TYPE='maven'
    fi
    if [[ -f 'build.gradle' ]]; then
        BUILD_TYPE='gradle'
    fi
else

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

            *)
                echo "Unknown build type $BUILD_TYPE"
                exit 1;
    esac
fi


echo ">>> checking for packaged deps"

# determine dependency store path and checksum
if [[ "$BUILD_TYPE" == "gradle" ]]; then
    DEPS_SUM=`md5sum build.gradle | awk '{ print $1 }'`
    DEPS_DIR="/root/.gradle/caches"

elif [[ "$BUILD_TYPE" == "maven" ]]; then
    # recursive find all pom.xml generate single hash of hashes
    DEPS_SUM=`find . -type f -name pom.xml -exec md5sum "{}" + | sort | md5sum | awk '{ print $1 }'`
    DEPS_DIR="/root/.m2/repository"

elif [[ "$BUILD_TYPE" == "nodejs" ]]; then
    # recursive find all package.json generate single hash of hashes
    DEPS_SUM=`find . -type f -name package.json -exec md5sum "{}" + | sort | md5sum | awk '{ print $1 }'`
    DEPS_DIR="/usr/workspace/clone/node_modules"
fi

echo "BUILD_TYPE=$BUILD_TYPE"
echo "DEPS_SUM=$DEPS_SUM"
echo "DEPS_DIR=$DEPS_DIR"
echo "AWS_S3_PROXY=$AWS_S3_PROXY"
echo "S3_DEPENDENCY_BUCKET=$S3_DEPENDENCY_BUCKET"
echo "IAM_ENABLED=$IAM_ENABLED"

# creds
if [[ "$IAM_ENABLED" != "true" ]]; then
    echo ">>> setting aws creds."
    export AWS_REGION=$GTM_AWS_REGION
    export AWS_ACCESS_KEY_ID=$GTM_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$GTM_AWS_SECRET_ACCESS_KEY
else
    echo ">>> using iam role.."
fi

# retrieve dependency bundle
if [[ "$S3_DEPENDENCY_BUCKET" != "" ]]; then
    if [[ `https_proxy=$AWS_S3_PROXY aws s3 ls s3://$S3_DEPENDENCY_BUCKET/deps/deps-$DEPS_SUM.tar.gz` ]]; then
        echo ">>> found dependency bundle in s3://$S3_DEPENDENCY_BUCKET/deps/deps-$DEPS_SUM.tar.gz"
        DEPS_FOUND="true"
        mkdir -p $DEPS_DIR
        echo ">>> downloading deps-$DEPS_SUM.tar.gz"
        https_proxy=$AWS_S3_PROXY aws s3api get-object --bucket $S3_DEPENDENCY_BUCKET --key deps/deps-$DEPS_SUM.tar.gz deps-$DEPS_SUM.tar.gz
        echo ">>> unpacking deps-$DEPS_SUM.tar.gz to $DEPS_DIR"
        tar --warning=no-timestamp -xzf deps-$DEPS_SUM.tar.gz -C "$DEPS_DIR"
    fi
fi

cd /usr/workspace/

