#!/bin/bash

cd /usr/workspace

# clone scripts repo
echo "GTM_WORKER_SCRIPTS_CLONE=$GTM_WORKER_SCRIPTS_CLONE"
echo "GTM_WORKER_SCRIPTS_PATH=$GTM_WORKER_SCRIPTS_PATH"

if [[ -n "$GTM_WORKER_SCRIPTS_CLONE" ]] && [[ -n "$GTM_WORKER_SCRIPTS_PATH" ]]; then
    echo ">>> cloning scripts repo.."
    mkdir scripts
    git clone --recursive $GTM_WORKER_SCRIPTS_CLONE scripts
    echo ">>> overlaying scripts"
    cp -rf scripts/$GTM_WORKER_SCRIPTS_PATH/* /usr/workspace/
fi

