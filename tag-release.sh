#!/bin/bash

echo $1 > .version
git add .version
git commit -m "version $1"
git push
git tag $1
git push origin --tags
echo "release $1 dockerhub build in progress."
