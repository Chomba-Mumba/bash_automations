#!/bin/bash

MFA_DEVICE_ARN=""
SOURCE_PROFILE="default" 
SESSION_PROFILE="mfa"    

read -p "Enter MFA Code: " MFA_CODE

#check if current credentials expired
EXPIRATION=$(aws configure get expiration --profile $SESSION_PROFILE)

EXPIRY_TIME=$(date -d "$EXPIRATION" +%s)
NOW_TIME=$(date +%s)

if [ "$NOW_TIME" -ge "$EXPIRY_TIME" ]; then
    echo "session has expired, resetting credentials"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCCESS_KEY
    unset AWS_SESSION_TOKEN
else
    TIME_LEFT=$((EXPIRY_TIME - NOW_TIME))
    echo "credentials still valid."
fi

# get session credentials using mfa
CREDS=$(aws sts get-session-token \
  --serial-number $MFA_DEVICE_ARN \
  --token-code $MFA_CODE \
  --duration-seconds 129600 \
  --profile $SOURCE_PROFILE \
  --output json)

# check for error
if [[ $? -ne 0 ]]; then
  echo "failed to get session token. Check your MFA code and credentials in profile '$SOURCE_PROFILE'."
  exit 1
fi

# extract credentials
AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.Credentials.SessionToken')

# save credentials to mfa profile
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile $SESSION_PROFILE
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile $SESSION_PROFILE
aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile $SESSION_PROFILE

echo "Temporary MFA credentials set in profile '$SESSION_PROFILE'. Use it like:"
echo "  aws s3 ls --profile $SESSION_PROFILE"

echo "Exporting temporary credentials into environment..."
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN