# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Official TensorFlow image published by TensorFlow
# https://www.tensorflow.org/install/docker
# latest  2.5.0 at the time of writing
FROM tensorflow/tensorflow:2.5.0

# Install the AWS CLI:
# AWS CLI dependencies, these are not in docker image
# shap package needs gcc which is install using build-essential
USER root
RUN apt-get update && \
    apt-get install -y curl wget unzip vim && \
    apt-get install -y groff groff-base less && \
    apt-get install -y build-essential && \
    apt-get clean

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip
RUN ./aws/install

# install jq to parse json within bash scripts
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
  chmod +x /usr/local/bin/jq

USER $NB_UID
# Install various Python utilities for SageMaker
# (Pinned to last tested major version for repeatability)
RUN pip install ipykernel && \
    python -m ipykernel install --sys-prefix && \
    pip install \
        'boto3>=1,<2' \
        'sagemaker>=2,<3' \
        'sagemaker-experiments>=0.1,<0.2' \
        'sagemaker-studio-image-build>=0.4,<0.5' \
        'smdebug>=0.9,<0.10'

COPY setup-ds-env.sh /root/setup-ds-env.sh
COPY code-artifact-login.sh /root/code-artifact-login.sh
COPY notebooks/ /root/notebooks/
