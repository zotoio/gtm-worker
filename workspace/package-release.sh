#!/bin/bash

PACKAGE=$1

echo 'Packaging ' $PACKAGE ' for release.';
cd /usr/workspace/clone/packages/$PACKAGE

echo "TODO collect production environment variables for package.."

if grep -q "sls-package" ./package.json; then
    yarn sls-package >> ${OUT_FILE} 2>&1 || echo "failed $PACKAGE..";
else
    echo "npm script for packaging $PACKAGE is missing" >> ${OUT_FILE}
fi