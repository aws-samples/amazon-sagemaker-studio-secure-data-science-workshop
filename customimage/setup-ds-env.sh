#!/bin/bash
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
set -e

# NOTE: Update these variables before executing this script
#       AWS_DEFAULT_REGION is already defined by SageMaker as environment variable in the container
DS_SHARED_SERVICE_STACK_SET_NAME=DSSharedServices # default from workshop, update if different
ENV_TYPE=dev # default from workshop, update if different
TEAM_NAME=fsi-smteam # default from workshop, update if different
USER_NAME=UPDATE_ME #  user name for git
USER_EMAIL=UPDATE_ME #  user email for git>

# Detect directory of this script
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#############################################
## Create a simple Python library to make building VPC-based SageMaker resources easier
#############################################
echo Building SageMaker convenience module:
echo Sensing network settings...
## Configure the approriate VPC, subnet, security group values based on values in Parameter Store

VPC_ID=`aws ssm get-parameter --name ds-vpc-${DS_SHARED_SERVICE_STACK_SET_NAME}-id --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
SUBNET_1=`aws ssm get-parameter --name ds-subnet-a-${DS_SHARED_SERVICE_STACK_SET_NAME}-id --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
SUBNET_2=`aws ssm get-parameter --name ds-subnet-b-${DS_SHARED_SERVICE_STACK_SET_NAME}-id --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
SUBNET_3=`aws ssm get-parameter --name ds-subnet-c-${DS_SHARED_SERVICE_STACK_SET_NAME}-id --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
SG_ID=`aws ssm get-parameter --name ds-sagemaker-vpc-sg-${DS_SHARED_SERVICE_STACK_SET_NAME}-id --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
KMS_ARN=`aws ssm get-parameter --name ds-kms-cmk-${TEAM_NAME}-${ENV_TYPE}-arn --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
S3_DATA_BUCKET=`aws ssm get-parameter --name ds-s3-data-bucket-${TEAM_NAME}-${ENV_TYPE} --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
S3_MODEL_BUCKET=`aws ssm get-parameter --name ds-s3-model-artifact-bucket-${TEAM_NAME}-${ENV_TYPE} --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`
SHARED_DATA_LAKE_BUCKET=`aws ssm get-parameter --name ds-s3-data-lake-bucket-${DS_SHARED_SERVICE_STACK_SET_NAME} --region ${AWS_DEFAULT_REGION} --query 'Parameter.Value' --output text`

echo Writing convenience module...
## Create the python module in the iPython directory which should be in every Python kernel path
mkdir -p ${HOME}/.ipython
cat <<EOF > ${HOME}/.ipython/sagemaker_environment.py
SAGEMAKER_VPC="$VPC_ID"
SAGEMAKER_SUBNETS = ["$SUBNET_1", "$SUBNET_2", "$SUBNET_3"]
SAGEMAKER_SECURITY_GROUPS = ["$SG_ID"]
SAGEMAKER_KMS_KEY_ID = "$KMS_ARN"
SAGEMAKER_DATA_BUCKET = "${S3_DATA_BUCKET}"
SAGEMAKER_MODEL_BUCKET = "${S3_MODEL_BUCKET}"
SAGEMAKER_DATA_LAKE_BUCKET = "${SHARED_DATA_LAKE_BUCKET}"
EOF

# Configure git
echo Configuring Git tooling...
git config --global user.name $USER_NAME
git config --global user.email $USER_EMAIL

# Clone workshop repo
#echo Cloning data science team CodeCommit repository...
#git clone https://git-codecommit.${AWS_DEFAULT_REGION}.amazonaws.com/v1/repos/ds-source-${TEAM_NAME}-${ENV_TYPE} $HOME/work/ds-source-${TEAM_NAME}-${ENV_TYPE}

## Configure  PIP to use AWS CodeArtifact
$SCRIPT_PATH/code-artifact-login.sh
