#! /bin/bash
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
set -e

# Set AWS_ACCOUNT_ID, AWS_DEFAULT_REGION, AWS_PROFILE variables in env if needed before running this script
if [[ -z "${AWS_ACCOUNT_ID}" ]]; then
  echo "AWS_ACCOUNT_ID environment variable undefined, please define this environment variable and try again"
  exit 1
fi

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
  echo "AWS_DEFAULT_REGION environment variable undefined, please define this environment variable and try again"
  exit 1
fi

STACK_SET_NAME=DSSharedServices #<SHARED SERVICES STACK SET NAME>
REPOSITORY_NAME=ds-shared-container-images
IMAGE_NAME=ds-custom-tensorflow241
DISPLAY_NAME="Custom TensorFlow v2.4.1 Image"

# create a repository in ECR, and then login to ECR repository
#aws ecr create-repository --repository-name ${REPOSITORY_NAME}
aws ecr get-login-password | docker login --username AWS \
  --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPOSITORY_NAME}

# cp data science setup script
cp ../setup-ds-env.sh .
cp ../code-artifact-login.sh .

# copy example notebooks
cp -r ../../src/project_template notebooks

# Build the docker image and push to Amazon ECR (modify image tags and name as required)
docker build . -t ${IMAGE_NAME} -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_NAME}
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_NAME}

# remove copied files
rm -rf setup-ds-env.sh
rm -rf code-artifact-login.sh
rm -rf notebooks

# Using with SageMaker Studio
## Create SageMaker Image with the image in ECR (modify image name as required)
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/ds-administrator-role-${STACK_SET_NAME}"

aws sagemaker create-image \
    --image-name ${IMAGE_NAME} \
    --display-name "${DISPLAY_NAME}" \
    --role-arn ${ROLE_ARN}

aws sagemaker create-image-version \
    --image-name ${IMAGE_NAME} \
    --base-image "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_NAME}"

## Verify the image-version is created successfully. Do NOT proceed if image-version is in CREATE_FAILED state or in any other state apart from CREATED.
aws sagemaker describe-image-version --image-name ${IMAGE_NAME}
#
## Create AppImageConfig for this image
#aws sagemaker create-app-image-config --cli-input-json file://app-image-config-input.json

# Not ready to create or update a domain
# Create domain
#aws sagemaker create-domain --cli-input-json file://create-domain-input.json
# OR
# Update domain
#aws sagemaker update-domain --cli-input-json file://update-domain-input.json