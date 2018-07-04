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

# perform deployment
yarn sls-deploy --alias $GIT_PUSH_BRANCHNAME > ${OUT_FILE} 2>&1 || echo "failed $PACKAGE..";

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
fi
cd /usr/workspace/
echo 'Success: ' $PACKAGE >> ${OUT_FILE};
