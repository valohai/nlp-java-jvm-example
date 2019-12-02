#!/bin/bash

#
# Copyright 2019 Mani Sarkar
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)"
source ${SCRIPT_DIR}/common.sh

if [[ -f /.dockerenv ]]; then
	SHARED_FOLDER="../shared/"
else
	SHARED_FOLDER="../../../shared/"
fi

mkdir -p ${SHARED_FOLDER}
cd ${SHARED_FOLDER}

FOLDER=apache-opennlp-1.9.1-bin
ARTIFACT=${FOLDER}.tar.gz

echo "Starting to download and unpack ${ARTIFACT}"
downloadArtifact http://apache.mirror.anlx.net/opennlp/opennlp-1.9.1/${ARTIFACT} \
                 ${ARTIFACT}                                 \
                 "${PWD}/${FOLDER}"
cd -
echo "Finished downloading and unpacking ${ARTIFACT} in ${PWD}/${FOLDER}"