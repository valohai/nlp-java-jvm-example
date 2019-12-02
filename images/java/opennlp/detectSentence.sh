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

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
source ${SCRIPT_DIR}/common-functions.sh

showUsageText() {
    cat << HEREDOC
       Detecting sentences in a single line text or article.

       Usage: $0 --text [text]
                 --file [path/to/filename]
                 --help

       --text            plain text surrounded by quotes
       --file            name of the file containing text to pass as command arg
       --help            shows the script usage help text

HEREDOC

	exit 1
}

MODEL_VERSION=1.5
MODEL_FILENAME="${language}-sent.bin"
APACHE_OPENNLP_CMD="${OPENNLP_BINARY} SentenceDetector ${SHARED_FOLDER}/${MODEL_FILENAME}"

checkIfNoParamHasBeenPassedIn "$#"

while [[ "$#" -gt 0 ]]; do case $1 in
  --help)                showUsageText;
                         exit 0;;
  --text)                PLAIN_TEXT="${2:-}";
                         checkIfApacheOpenNLPIsPresent
                         downloadModel;
                         echo ${PLAIN_TEXT} | ${APACHE_OPENNLP_CMD};
                         exit 0;;
  --file)                FILENAME="${2:-}";
                         checkIfApacheOpenNLPIsPresent
                         downloadModel;
                         cat ${FILENAME}    | ${APACHE_OPENNLP_CMD};
                         exit 0;;
  *) echo "Unknown parameter passed: $1";
     showUsageText;
esac; shift; done