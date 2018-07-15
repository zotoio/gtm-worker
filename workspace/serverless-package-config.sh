#!/bin/bash

# Collect config and write to files/env.  Sensitive values should be pre-encrypted using the
# kms key your functions are configured to use. ie. GTM_SLS_EXECUTOR_AWS_KMS_KEY_ID
PACKAGE=$1
STAGE=$2
echo "Collecting package configuration for $PACKAGE ($STAGE).."

mkdir -p /usr/workspace/clone/output/$PACKAGE
touch /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh

case "$SLS_CONFIG_TYPE" in
    ssm)
        # use AWS SSM Parameter Store to collect package config for stage
        # aws ssm put-parameter --name "/serverless/sample-http/dev/SAMPLE_VAR" --type "String" --value "some value"
        # aws ssm get-parameters-by-path --path /serverless/$PACKAGE/$STAGE
        echo "Using AWS SSM Parameter Store.."
        aws ssm get-parameters-by-path --path /serverless/${PACKAGE}/${STAGE} \
        | jq -r '.Parameters| .[] | "export " + .Name + "=\"" + .Value + "\""  ' \
        | sed -e "s~/serverless/${PACKAGE}/${STAGE}/~~" >> /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh
        ;;

    spring)
        # Use spring config server rest endpoint https://github.com/spring-cloud/spring-cloud-config
        # a local docker based example can be started with ./docker-spring-config.sh reading /config/**
        # use SPRING_CONFIG_ENDPOINT=http://localhost:8888
        echo "Using spring config server.."
        curl ${SLS_SPRING_CONFIG_ENDPOINT}/serverless/${PACKAGE}-${STAGE}.json \
        | jq -r 'keys[] as $k | select($k != "spring") | "export " + $k + "=\"" + .[$k] + "\""' \
        >> /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh
        ;;

    *)
        # Use config from committed package dir env files for each stage
        # .env is picked up by sls-deploy script, so just copying from .env-$STAGE
        echo "Defaulting to dotenv.."
        if [[ -f /usr/workspace/clone/packages/$PACKAGE/.env-$STAGE ]]; then
            cp /usr/workspace/clone/packages/$PACKAGE/.env-$STAGE /usr/workspace/clone/packages/$PACKAGE/.env
            cp /usr/workspace/clone/packages/$PACKAGE/.env-$STAGE /usr/workspace/clone/output/$PACKAGE/.env-$STAGE
            cat /usr/workspace/clone/packages/$PACKAGE/.env
        fi
esac

cat /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh
source /usr/workspace/clone/output/$PACKAGE/set-env-$STAGE.sh

