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

language=en
MODEL_VERSION=1.5

APACHE_OPENNLP_VERSION=1.9.1
if [[ -f /.dockerenv ]]; then
	SHARED_FOLDER="../shared/"
else
	SHARED_FOLDER="../../../shared/"
fi

URL_PREFIX="http://opennlp.sourceforge.net/models-"
OPENNLP_BINARY="${SHARED_FOLDER}/apache-opennlp-${APACHE_OPENNLP_VERSION}/bin/opennlp"

checkIfApacheOpenNLPIsPresent() {
  if [[ ! -s "${OPENNLP_BINARY}" ]]; then
    echo "Can't find "${OPENNLP_BINARY}" needed to run this action."
    echo "Please run the docker container (see usage of the docker-runner.sh script in the previous folder)."
    echo "Or run the opennlp.sh script in this folder, and try again..."
    exit -1
  fi
}

downloadModel() {
	echo "Checking if model ${MODEL_FILENAME} (${language}) exists..."
	if [[ -s "${SHARED_FOLDER}/${MODEL_FILENAME}" ]]; then
		echo "Found model ${MODEL_FILENAME} (${language}) in '${SHARED_FOLDER}'"
	else
		echo "Downloading model ${MODEL_FILENAME} (${language}) in '${SHARED_FOLDER}'"
		curl -O -J -L \
		     "${URL_PREFIX}${MODEL_VERSION}/${MODEL_FILENAME}"
        mkdir -p ${SHARED_FOLDER}
        mv ${MODEL_FILENAME} ${SHARED_FOLDER}
	fi
}

checkIfNoParamHasBeenPassedIn() {
	if [[ $1 -eq 0 ]]; then
		echo "No parameter has been passed. Please see usage below:"
		echo "";
		showUsageText
	fi
}

checkIfNoActionParamHasBeenPassedIn() {
	if [[ $1 -eq 0 ]]; then
		echo "No command action passed in as parameter. Please see usage below:"
		echo "";
		showUsageText
	fi	
}

showHelpForTagLegend() {
  echo ""; 
  echo "Check out https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html 
  to find out what each of the tags mean"
}

showHelpForLanguageLegend() {
  echo ""; 
  echo "Check out https://www.apache.org/dist/opennlp/models/langdetect/1.8.3/README.txt to find out what each of the two-letter language indicators mean"
}