#!/bin/bash
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Set AWS_PROFILE in environment if needed
aws sagemaker create-presigned-domain-url --cli-input-json file://pre-signedurl-input.json