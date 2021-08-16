#!/bin/bash

# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Environment variables used in various scripts used in the workshop
# Update them for your environment
# In a bash shell terminal execute `. workshop-env.sh or source workshop-env.sh` to setup the environment
if [[ -z "${C9_PROJECT}" ]]; then
  echo "Not in AWS Cloud9 environment"
  export AWS_ACCOUNT_ID=#<AWS Account Number>
  export AWS_DEFAULT_REGION=#<AWS_DEFAULT_REGION>
else
  # In Cloud9
  echo "In AWS Cloud9 environment"
  export AWS_ACCOUNT_ID=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|jq -r .accountId`
  export AWS_DEFAULT_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|jq -r .region`
fi

echo "AWS_ACCOUNT_ID set to $AWS_ACCOUNT_ID"
echo "AWS_DEFAULT_REGION set to $AWS_DEFAULT_REGION"

# set if other than "default"
#export AWS_PROFILE=#<AWS PROFILE>

