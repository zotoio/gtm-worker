#!/bin/bash

# collect config and write to files/env
PACKAGE=$1
STAGE=$2
echo "Collecting package configuration for $PACKAGE ($STAGE).."

# aws ssm put-parameter --name "/serverless/sample-http/dev/SAMPLE_VAR" --type "String" --value "some value"
# aws ssm get-parameters-by-path --with-decryption --path /serverless/$PACKAGE/$STAGE

mkdir -p /usr/workspace/clone/output/$PACKAGE
touch /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh
aws ssm get-parameters-by-path --with-decryption --path /serverless/${PACKAGE}/${STAGE} \
| jq -r '.Parameters| .[] | "export " + .Name + "=\"" + .Value + "\""  ' \
| sed -e "s~/serverless/${PACKAGE}/${STAGE}/~~" >> /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh

cat /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh

source /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh

