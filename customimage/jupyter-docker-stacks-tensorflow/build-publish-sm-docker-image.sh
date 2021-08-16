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