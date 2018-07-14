# creds
if [[ "$IAM_ENABLED" != "true" ]]; then
    echo ">>> setting aws creds."
    export AWS_DEFAULT_REGION=$GTM_AWS_REGION
    export AWS_ACCESS_KEY_ID=$GTM_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$GTM_AWS_SECRET_ACCESS_KEY
else
    echo ">>> using iam role.."
fi