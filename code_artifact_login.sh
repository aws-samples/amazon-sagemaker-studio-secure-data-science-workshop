#!/bin/bash
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -e

# This script configures pip to use Code Artifact as PYPI repository.
#
# This script should be run after code artifact has been created in the target AWS account.
#
# The script requires CodeArtifact Admin permissions, add following Managed Policy to Role used to run the script:
# arn:aws:iam::aws:policy/AWSCodeArtifactAdminAccess
#
# This script assumes a Linux or MacOSX environment and relies on the following software packages being installed:
# . - AWS Command Line Interface (CLI) v2 latest version that supports codeartifact commands
# . - Python 3 / pip3

# Modify the variables for your environment
# DOMAIN_OWNER is AWS Account Number
CODE_ARTIFACT_DOMAIN_OWNER=${AWS_ACCOUNT_ID}
DS_SHARED_CODE_ARTIFACT_DOMAIN=ds-domain
DS_SHARED_CODE_ARTIFACT_REPO=ds-shared-repo
# Set  AWS_PROFILE variables in environment if needed

# Login to CodeArtifact which will setup pip.conf in $HOME/.config/pip/pip.conf
aws codeartifact login --tool pip \
 --domain ${DS_SHARED_CODE_ARTIFACT_DOMAIN} \
 --domain-owner ${CODE_ARTIFACT_DOMAIN_OWNER} \
 --repository ${DS_SHARED_CODE_ARTIFACT_REPO}

