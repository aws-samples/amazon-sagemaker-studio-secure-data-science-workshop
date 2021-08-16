#!/bin/bash

# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -e

# This script will package the CloudFormation in this directory, and the source code in this repository, and upload it 
# to Amazon S3 in preparation for deployment using the AWS CloudFormation service.
# 
# This script exists because Service Catalog products, when using relative references to cloudformation templates are 
# not properly packaged by the AWS cli. Also the full stack, due to 2 levels of Service Catalog deployment will not 
# always package properly using the AWS cli.

# This script treats the templates as source code and packages them, putting the results into a 'build' subdirectory.

# This script assumes a Linux or MacOSX environment and relies on the following software packages being installed:
# . - AWS Command Line Interface (CLI)
# . - sed
# . - Python 3 / pip3
# . - zip

# PLEASE NOTE this script will store all resources to an Amazon S3 bucket s3://${CFN_BUCKET_NAME}/${PROJECT_NAME}
# Set AWS_DEFAULT_REGION and AWS_PROFILE variables in environment if needed
QUICKSTART_MODE=true
CFN_BUCKET_NAME=${CFN_BUCKET_NAME:="secure-data-science-cloudformation-$RANDOM-$AWS_DEFAULT_REGION"}
PROJECT_NAME="quickstart"
# files that won't be uploaded by `aws cloudformation package`
UPLOAD_LIST="ds_environment.yaml project_template.zip ds_administration.yaml ds_env_studio_user_profile_v1.yaml ds_env_studio_user_profile_v2.yaml ds_env_sagemaker_studio.yaml"
# files that need to be scrubbed with sed to replace < S3_CFN_STAGING_BUCKET > with an actual S3 bucket name
SELF_PACKAGE_LIST="ds_administration.yaml ds_env_backing_store.yaml"
# files to be packaged using `aws cloudformation package`
AWS_PACKAGE_LIST="ds_environment.yaml ds_administration.yaml"
TMP_OUTPUT_DIR="/tmp/build/${AWS_DEFAULT_REGION}"
PUBLISH_PYPI=${PUBLISH_PYPI:True}

if aws s3 ls s3://${CFN_BUCKET_NAME} 2>&1 | grep NoSuchBucket
then
    echo Creating Amazon S3 bucket ${CFN_BUCKET_NAME}
    aws s3 mb s3://${CFN_BUCKET_NAME}
    aws s3api put-public-access-block --bucket ${CFN_BUCKET_NAME} --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
fi
echo Preparing content for publication to Amazon S3 s3://${CFN_BUCKET_NAME}

## clean away any previous builds of the CFN
rm -fr ${TMP_OUTPUT_DIR}
mkdir -p ${TMP_OUTPUT_DIR}
cp cloudformation/*.yaml ${TMP_OUTPUT_DIR}

echo "Zipping code sample..."
pushd src/project_template
zip -r ${TMP_OUTPUT_DIR}/project_template.zip ./*
popd

echo "Zipping detective control..."
pushd src/detective_control
zip -r ${TMP_OUTPUT_DIR}/vpc_detective_control.zip ./*
popd

## publish materials to target AWS regions
REGION=${AWS_DEFAULT_REGION:="us-west-2"}
echo Publishing CloudFormation to ${REGION}

echo "Clearing ${CFN_BUCKET_NAME}..."

echo "Self-packaging some Cloudformation templates..."
for fname in ${SELF_PACKAGE_LIST};
do
    sed -ie "s/< S3_CFN_STAGING_PATH >/${PROJECT_NAME}/" ${TMP_OUTPUT_DIR}/${fname}
    sed -ie "s/< S3_CFN_STAGING_BUCKET >/${CFN_BUCKET_NAME}/" ${TMP_OUTPUT_DIR}/${fname}
    sed -ie "s/< S3_CFN_STAGING_BUCKET_PATH >/${CFN_BUCKET_NAME}\/${PROJECT_NAME}/" ${TMP_OUTPUT_DIR}/${fname}
done

echo "Packaging Cloudformation templates..."
for fname in ${AWS_PACKAGE_LIST};
do
    pushd ${TMP_OUTPUT_DIR}
    aws cloudformation package \
        --template-file ${fname} \
        --s3-bucket ${CFN_BUCKET_NAME} \
        --s3-prefix ${PROJECT_NAME} \
        --output-template-file ${TMP_OUTPUT_DIR}/${fname}-${REGION} \
        --region ${REGION}
    popd
done

# push files to S3, note this does not 'package' the templates
echo "Copying cloudformation templates and files to S3..."
for fname in ${UPLOAD_LIST};
do
    if [ -f ${TMP_OUTPUT_DIR}/${fname}-${REGION} ]; then
        aws s3 cp ${TMP_OUTPUT_DIR}/${fname}-${REGION} s3://${CFN_BUCKET_NAME}/${PROJECT_NAME}/${fname}
    else
        aws s3 cp ${TMP_OUTPUT_DIR}/${fname} s3://${CFN_BUCKET_NAME}/${PROJECT_NAME}/${fname}
    fi
done

echo ==================================================
echo "Publication complete"
echo "To deploy execute:"
echo "   aws cloudformation create-stack --template-url https://s3.${REGION}.amazonaws.com/${CFN_BUCKET_NAME}/${PROJECT_NAME}/ds_administration.yaml --region ${REGION} --stack-name secure-ds-shared-service --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=QuickstartMode,ParameterValue=${QUICKSTART_MODE} "
