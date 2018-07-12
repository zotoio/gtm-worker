#!/bin/bash

display_usage() {
    echo "Please supply a new semver tag - look at .version for last release."
    echo "eg. ./tag-release.sh.sh 1.6.4"
    echo "it looks like the last version was" `cat .version`
}

if [ $# -eq 0 ]; then
    display_usage
    exit 1
fi

echo $1 > .version
git add .version
git commit -m "version $1"
git push
git tag $1
git push origin --tags
echo "release $1 dockerhub build in progress."
