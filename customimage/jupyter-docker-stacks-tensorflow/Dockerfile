# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# TensorFlow image published by jupyter-docker-stacks
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-tensorflow-notebook
# latest is tensorflow 2.4.1 at the time of writing
FROM jupyter/tensorflow-notebook:latest

# Install the AWS CLI:
# AWS CLI dependencies, these are not in docker image
# shap package needs gcc which is install using build-essential
USER root
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y groff groff-base less && \
    apt-get install -y build-essential && \
    apt-get clean

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip
RUN ./aws/install

# install jq to parse json within bash scripts
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
  chmod +x /usr/local/bin/jq

COPY --chown=${NB_UID}:${NB_GID} setup-ds-env.sh "/home/${NB_USER}/bin/setup-ds-env.sh"
COPY --chown=${NB_UID}:${NB_GID} code-artifact-login.sh "/home/${NB_USER}/bin/code-artifact-login.sh"
COPY --chown=${NB_UID}:${NB_GID} notebooks/ "/home/${NB_USER}/notebooks/"

USER ${NB_UID}
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

# Use pip install for the lab, shap requires gcc, it is installed above
# RUN conda install -c conda-forge shap
