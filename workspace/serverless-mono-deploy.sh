#!/bin/bash

# this is intended to operate on a lerna mono repo generated by zotoio/generator-mono-serverless

set -e

START=`date +%s`

echo "GTM_EVENT_ID=$GTM_EVENT_ID"
echo "SLS_AWS_STAGE=$SLS_AWS_STAGE"
echo "GIT_PUSH_BRANCHNAME=$GIT_PUSH_BRANCHNAME"
echo "GIT_PR_ID=$GIT_PR_ID"
echo "SLS_DEPLOY_MODE=$SLS_DEPLOY_MODE"

cd /usr/workspace

source ./clone.sh

if [ -n "$GIT_PR_ID" ]; then
    source fetch-pullrequest.sh
else
    if [ -n "$GIT_PUSH_BRANCHNAME" ]; then
        cd /usr/workspace/clone
        git checkout $GIT_PUSH_BRANCHNAME
    fi
fi

cd /usr/workspace/
export BUILD_COMMAND=yarn
source ./deps.sh
source ./build.sh

echo
echo "looks like we need to deploy $SLS_AFFECTED_PACKAGES .."

export IFS=","
mkdir -p /usr/workspace/clone/output

if [[ "$SLS_DEPLOY_MODE" = "sequential" ]]; then
    for PACKAGE in $SLS_AFFECTED_PACKAGES; do
        echo 'Deploying package' $PACKAGE '..';
        cd /usr/workspace/clone/packages/$PACKAGE
        OUTPUT_FILENAME=`date +%Y-%m-%d-%H%M%S`-${GTM_EVENT_ID:0:8}-$PACKAGE-output.txt;
        yarn sls-deploy --alias $GIT_PUSH_BRANCHNAME | tee /usr/workspace/clone/output/${OUTPUT_FILENAME}
        if [[ -f 'artillery.yml' ]]; then
            echo 'Running artillery perf test';
            yarn sls-perf > /usr/workspace/clone/output/perf-${OUTPUT_FILENAME} 2>&1;
            yarn sls-perf-report | tee /usr/workspace/clone/output/perf-${OUTPUT_FILENAME}
        fi
    done

else
    # default is to deploy function in parallel - up to 4 simultaneously
    for PACKAGE in ${SLS_AFFECTED_PACKAGES[*]}; do
        echo ${PACKAGE}^${GTM_EVENT_ID}^${GIT_PUSH_BRANCHNAME}^${SLS_AWS_STAGE};
    done | xargs -I{} --max-procs 4 ./serverless-deploy.sh {}
    cat /usr/workspace/clone/output/*-summary.txt
fi

echo "ApiGateway Endpoints:"
cat /usr/workspace/clone/output/*-output.txt | grep 'POST\|GET' | sed "s/\/${SLS_AWS_STAGE}\//\/${GIT_PUSH_BRANCHNAME}\//g"

if grep -q "error Command failed with exit code" /usr/workspace/clone/output/*-output.txt; then
    echo "AT LEAST ONE DEPLOY FAILED"
else
    echo "ALL DEPLOYS SUCCESSFUL"
fi

# store output
if [[ "$S3_DEPENDENCY_BUCKET" != "" ]]; then
    echo ">>> packaging deployment output: ${GTM_EVENT_ID}-output.tar.gz from output dir.."
    tar -czf ${GTM_EVENT_ID}-output.tar.gz -C /usr/workspace/clone/output .
    echo ">>> uploading output to s3://${S3_DEPENDENCY_BUCKET}/output/${GTM_EVENT_ID}-output.tar.gz"
    https_proxy=$AWS_S3_PROXY aws s3api put-object --bucket $S3_DEPENDENCY_BUCKET --key output/${GTM_EVENT_ID}-output.tar.gz --body ${GTM_EVENT_ID}-output.tar.gz
fi

END=`date +%s`
echo "Execution time was `expr $END - $START` seconds."
