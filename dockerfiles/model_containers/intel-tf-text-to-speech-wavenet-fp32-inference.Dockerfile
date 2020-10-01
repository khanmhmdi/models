# Copyright (c) 2020 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
#
# THIS IS A GENERATED DOCKERFILE.
#
# This file was assembled from multiple pieces, whose use is documented
# throughout. Please refer to the TensorFlow dockerfiles documentation
# for more information.

ARG TENSORFLOW_IMAGE="intel/intel-optimized-tensorflow"
ARG TENSORFLOW_TAG

FROM ${TENSORFLOW_IMAGE}:${TENSORFLOW_TAG}


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends --fix-missing python-tk libsm6 libxext6 -y && \
    pip install requests


ARG TF_WAVENET_BRANCH
ARG FETCH_PR
ARG CODE_DIR=/tensorflow-wavenet

ENV TF_WAVENET_DIR=${CODE_DIR}

RUN apt-get update && \
    apt-get install -y git && \
    git clone https://github.com/ibab/tensorflow-wavenet.git ${CODE_DIR} && \
    ( cd ${CODE_DIR} && \
    if [ ! -z "$FETCH_PR" ]; then git fetch origin ${FETCH_PR}; fi && \
    git checkout ${TF_WAVENET_BRANCH} )


RUN pip install librosa==0.5

ARG PACKAGE_DIR=model_packages
ARG PACKAGE_NAME

ARG MODEL_WORKSPACE

# ${MODEL_WORKSPACE} and below needs to be owned by root:root rather than the current UID:GID
# this allows the default user (root) to work in k8s single-node, multi-node
RUN umask 002 && mkdir ${MODEL_WORKSPACE} && chgrp root ${MODEL_WORKSPACE} && chmod g+s+w,o+s+r ${MODEL_WORKSPACE}
ADD --chown=0:0 ${PACKAGE_DIR}/${PACKAGE_NAME}.tar.gz ${MODEL_WORKSPACE}
RUN chown -R root ${MODEL_WORKSPACE}/${PACKAGE_NAME} && chgrp -R root ${MODEL_WORKSPACE}/${PACKAGE_NAME} && chmod -R g+s+w ${MODEL_WORKSPACE}/${PACKAGE_NAME} && find ${MODEL_WORKSPACE}/${PACKAGE_NAME} -type d | xargs chmod o+r+x 

WORKDIR ${MODEL_WORKSPACE}/${PACKAGE_NAME}

RUN apt-get install -y tar


ENV USER_ID=0
ENV USER_NAME=root
ENV GROUP_ID=0
ENV GROUP_NAME=root

#TODO this needs to be approved by SDL
#See https://gitlab.devtools.intel.com/TensorFlow/QA/cje-tf/-/merge_requests/685#note_4718598
RUN apt-get update && apt-get install -y gosu
RUN echo '#!/bin/bash\n\
USER_ID=$USER_ID\n\
USER_NAME=$USER_NAME\n\
GROUP_ID=$GROUP_ID\n\
GROUP_NAME=$GROUP_NAME\n\
if [[ $GROUP_NAME != root ]]; then\n\
  groupadd -r -g $GROUP_ID $GROUP_NAME\n\
fi\n\
if [[ $USER_NAME != root ]]; then\n\
  useradd --no-log-init -r -u $USER_ID -g $GROUP_NAME -s /bin/bash -M $USER_NAME\n\
fi\n\
exec /usr/sbin/gosu $USER_NAME:$GROUP_NAME "$@"\n '\
>> /tmp/entrypoint.sh
RUN chmod u+x,g+x /tmp/entrypoint.sh
ENTRYPOINT ["/tmp/entrypoint.sh"]