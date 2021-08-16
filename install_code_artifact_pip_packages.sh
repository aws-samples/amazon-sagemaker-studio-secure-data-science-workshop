#!/bin/bash
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -e #-x

# This script installs pip packages in shared data science code artifact repository and disassociates external
# connection to public PyPI repository.
#
# This script should be run after code artifact has been created in the target AWS account.
#
# The script requires CodeArtifact Admin permissions, add following Managed Policy to Role used to run the script:
# arn:aws:iam::aws:policy/AWSCodeArtifactAdminAccess
#
# This script assumes a Linux or MacOSX environment and relies on the following software packages being installed:
# . - AWS Command Line Interface (CLI) v2 latest version that supports codeartifact commands
# . - Python 3 / pip3
#
# This script assumes you have configured pip to use AWS CodeArtifact, if not use the provided code_artifact_login.sh
# script to configure pip. Note that CodeArtifact token is by default valid for 12 hours, so you may have to run it again if
# token as expired.

# Modify the variables for your environment
# DOMAIN_OWNER is AWS Account Number
CODE_ARTIFACT_DOMAIN_OWNER=${AWS_ACCOUNT_ID}
DS_SHARED_CODE_ARTIFACT_DOMAIN=ds-domain
DS_SHARED_CODE_ARTIFACT_PUBLIC_UPSTREAM_REPO=ds-public-upstream-repo
EXTERNAL_CONNECTION_NAME=public:pypi # this doesn't change
# Set AWS_PROFILE variable in environment if needed

# Install pip packages, this will download and cache pip packages in CodeArtifact shared repo
pip3 install --no-cache-dir --user awswrangler==2.9.0 stepfunctions==2.2.0 smdebug==1.0.10 shap==0.39.0 sagemaker-experiments==0.1.33
pip3 install --no-cache-dir --user \
  --only-binary=:all: \
  numpy==1.20.3 pandas==1.2.5 protobuf==3.17.3 pyarrow==4.0.1 scikit-learn==0.24.2 scipy==1.7.0 psycopg2-binary xgboost==1.4.2

# Disassociate external public PyPI connection to restrict package download from public PYPI repo.
# AWS CodeArtifact service as of this writing by default will download packages from public PYPI repo
# if an external connection exists.
# The connection can be associated again to install new packages in the shared repo by using:
# aws codeartifact associate-external-connection
aws codeartifact disassociate-external-connection \
 --domain ${DS_SHARED_CODE_ARTIFACT_DOMAIN} \
 --domain-owner ${CODE_ARTIFACT_DOMAIN_OWNER} \
 --repository ${DS_SHARED_CODE_ARTIFACT_PUBLIC_UPSTREAM_REPO} \
 --external-connection ${EXTERNAL_CONNECTION_NAME}
