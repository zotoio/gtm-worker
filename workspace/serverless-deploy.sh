#!/bin/bash

# unpack vars
PACKVARS=$1
PACKAGE=$(echo $PACKVARS | cut -f1 -d^);
GTM_EVENT_ID=$(echo $PACKVARS | cut -f2 -d^);
GIT_PUSH_BRANCHNAME=$(echo $PACKVARS | cut -f3 -d^);
SLS_AWS_STAGE=$(echo $PACKVARS | cut -f4 -d^);

echo 'Deploying package' $PACKAGE '..';
cd /usr/workspace/clone/packages/$PACKAGE;

# output files
OUTDIR="/usr/workspace/clone/output";
OUTPUT_FILENAME_BASE=`date +%Y-%m-%d-%H%M%S`-${GTM_EVENT_ID:0:8}-$PACKAGE;
OUT_FILE=${OUTDIR}/${OUTPUT_FILENAME_BASE}-output.txt
ERR_FILE=${OUTDIR}/${OUTPUT_FILENAME_BASE}-error.txt
PERF_FILE=${OUTDIR}/${OUTPUT_FILENAME_BASE}-perf.txt
SUMMARY_FILE=${OUTDIR}/${GTM_EVENT_ID:0:8}-summary.txt;

# print evaluated config
if grep -q "sls-print" /usr/workspace/clone/packages/$PACKAGE/package.json; then
    yarn sls-print >> $OUTDIR/$PACKAGE-sls.yml 2>&1 || echo "failed printing config for $PACKAGE..";
else
    echo "npm script for printing config of $PACKAGE is missing"
fi

# perform deployment
https_proxy=$HTTP_PROXY no_proxy=$NO_PROXY yarn sls-deploy --alias $GIT_PUSH_BRANCHNAME >> ${OUT_FILE} 2>&1 || echo "deploy failed $PACKAGE..";

# run performance test
if [[ -f 'artillery.yml' ]]; then
    echo 'Running artillery perf test';
    echo "Performance test for " $PACKAGE > ${PERF_FILE};
    cat artillery.yml >> ${PERF_FILE} 2>&1;
    yarn sls-perf >> ${PERF_FILE} 2>&1;
    yarn sls-perf-report  >> ${PERF_FILE} 2>&1;
    cat ${PERF_FILE} 2>&1;
fi

# output results
cat ${OUT_FILE};
echo '### ' $PACKAGE ' tail #############' >> ${SUMMARY_FILE};
tail -25 ${OUT_FILE} >> ${SUMMARY_FILE};

if grep -q "error Command failed with exit code" ${OUT_FILE}; then
    cp ${OUT_FILE} ${ERR_FILE}
    echo 'FAILURE: ' $PACKAGE >> ${OUT_FILE};
    exit 1;
else
    # package up if master branch
    if [[ -f /usr/workspace/package-release.sh ]] && [[ "$GIT_PUSH_BRANCHNAME" = "master" ]]; then
        source /usr/workspace/package-release.sh $PACKAGE >> ${OUT_FILE} 2>&1 || echo "package failed $PACKAGE"
    fi
fi

cd /usr/workspace/
echo 'Success: ' $PACKAGE >> ${OUT_FILE};
