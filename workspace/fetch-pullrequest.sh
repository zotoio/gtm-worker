#!/bin/bash

cd /usr/workspace/clone

# fetch PR
if [ -n "$GIT_PR_ID" ]; then
    echo ">>> fetching pull request.."
    git fetch origin pull/$GIT_PR_ID/merge:$GIT_PR_BRANCHNAME

    git checkout $GIT_PR_BRANCHNAME
fi

cd /usr/workspace/
 