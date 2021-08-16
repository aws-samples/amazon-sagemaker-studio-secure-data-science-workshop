#!/bin/bash
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
set -e

# Configure  PIP
## get values from SSM Parameter Store
CODE_ARTIFACT_DOMAIN=`aws ssm get-parameter --name ds-codeartifact-domain-name  --query 'Parameter.Value' --output text`
DOMAIN_OWNER=`aws ssm get-parameter --name ds-codeartifact-domain-owner --query 'Parameter.Value' --output text`
CODE_ARTIFACT_REPO=`aws ssm get-parameter --name ds-codeartifact-repository --query 'Parameter.Value' --output text`
CODE_ARTIFACT_API_DNS=`aws ssm get-parameter --name ds-codeartifact-api-dns --query 'Parameter.Value' --output text`

## Configure PIP by calling CodeArtifact login, it automatically updates ${HOME}/.config/pip/pip.conf 
echo "Configuring pip to use CodeArtifact"
echo "aws codeartifact login --tool pip --domain ${CODE_ARTIFACT_DOMAIN} --domain-owner ${DOMAIN_OWNER} --repository ${CODE_ARTIFACT_REPO} --endpoint-url https://${CODE_ARTIFACT_API_DNS}"
aws codeartifact login --tool pip --domain ${CODE_ARTIFACT_DOMAIN} --domain-owner ${DOMAIN_OWNER} --repository ${CODE_ARTIFACT_REPO} --endpoint-url https://${CODE_ARTIFACT_API_DNS}
