#!/bin/bash

cd /usr/workspace/clone

# fetch PR
echo ">>> fetching pull request.."
git fetch origin pull/$GIT_PR_ID/merge:$GIT_PR_BRANCHNAME

git checkout $GIT_PR_BRANCHNAME

cd /usr/workspace/
 