#!/bin/bash

PACKVARS=$1
#echo $PACKVARS;
PACKAGE=$(echo $PACKVARS | cut -f1 -d^);
GTM_EVENT_ID=$(echo $PACKVARS | cut -f2 -d^);
GIT_PUSH_BRANCHNAME=$(echo $PACKVARS | cut -f3 -d^);
SLS_AWS_STAGE=$(echo $PACKVARS | cut -f4 -d^);
echo 'Deploying package' $PACKAGE '..';
cd /usr/workspace/clone/packages/$PACKAGE;
OUTPUT_FILENAME=`date +%Y-%m-%d-%H%M%S`-${GTM_EVENT_ID:0:8}-$PACKAGE-output.txt;
#echo $OUTPUT_FILENAME;
yarn sls-deploy --alias $GIT_PUSH_BRANCHNAME > /usr/workspace/clone/output/${OUTPUT_FILENAME} 2>&1;
cat /usr/workspace/clone/output/${OUTPUT_FILENAME};
SUMMARY_FILENAME=${GTM_EVENT_ID:0:8}-summary.txt;
echo '### ' $PACKAGE ' tail #############' >> /usr/workspace/clone/output/${SUMMARY_FILENAME};
tail -25 /usr/workspace/clone/output/${OUTPUT_FILENAME} >> /usr/workspace/clone/output/${SUMMARY_FILENAME};
echo 'Done' $PACKAGE;
