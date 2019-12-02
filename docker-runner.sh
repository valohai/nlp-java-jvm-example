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

findImage() {
	IMAGE_NAME=$1
	echo $(docker images ${IMAGE_NAME} -q | head -n1 || true)
}

getOpenCommand() {
  if [[ "$(uname)" = "Linux" ]]; then
     echo "xdg-open"
  elif [[ "$(uname)" = "Darwin" ]]; then
     echo "open"
  fi
}

runContainer() {
	askDockerUserNameIfAbsent
	setVariables

  ## When run in the console mode (command-prompt available)
  TOGGLE_ENTRYPOINT="--entrypoint /bin/bash"
  VOLUMES_SHARED="--volume "$(pwd)":${WORKDIR}/work --volume "$(pwd)"/shared:${WORKDIR}/shared"

	echo "";
	echo "Running container ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION}"; echo ""

	mkdir -p shared

	${TIME_IT} docker run                                      \
	            --rm                                           \
                ${INTERACTIVE_MODE}                          \
                ${TOGGLE_ENTRYPOINT}                         \
                -p ${HOST_PORT}:${CONTAINER_PORT}            \
                --workdir ${WORKDIR}                         \
                --env JDK_TO_USE=${JDK_TO_USE:-}             \
                --env JAVA_OPTS=${JAVA_OPTS:-}               \
                ${VOLUMES_SHARED}                            \
                "${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION}"
}

buildImage() {
	askDockerUserNameIfAbsent
	setVariables
	
	echo "Building image ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION}"; echo ""

	echo "* Fetching NLP base docker image ${BASE_FULL_DOCKER_TAG_NAME}:${BASE_IMAGE_VERSION} from Docker Hub"
	time docker pull ${BASE_FULL_DOCKER_TAG_NAME}:${BASE_IMAGE_VERSION} || true
	time docker build                                                  \
	             --build-arg WORKDIR=${WORKDIR}                        \
	             --build-arg JAVA_9_HOME="/opt/java/openjdk"           \
	             --build-arg GRAALVM_HOME="/opt/java/graalvm"          \
	             --build-arg CONTAINER_GROUP=${CONTAINER_GROUP}        \
	             --build-arg CONTAINER_USER=${CONTAINER_USER}          \
	             -t ${BASE_FULL_DOCKER_TAG_NAME}:${BASE_IMAGE_VERSION} \
	             "${IMAGES_DIR}/base/."
	echo "* Finished building NLP base docker image ${BASE_FULL_DOCKER_TAG_NAME}:${BASE_IMAGE_VERSION}"

	echo "* Fetching NLP ${language_id} docker image ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION} from Docker Hub"
	time docker pull ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION} || true
	time docker build                                                                        \
	             --build-arg BASE_IMAGE="${BASE_FULL_DOCKER_TAG_NAME}:${BASE_IMAGE_VERSION}" \
	             --build-arg CONTAINER_GROUP=${CONTAINER_GROUP}                              \
	             --build-arg CONTAINER_USER=${CONTAINER_USER}                                \
	             -t ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION}                                 \
	             "${IMAGES_DIR}/${language_id}/."
	echo "* Finished building NLP ${language_id} docker image ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION}"
	
	cleanup
	pushImageToHub
	cleanup
}

pushImage() {
	IMAGE_NAME="nlp-${2:-${language_id}}"
    IMAGE_VERSION=$(cat images/${language_id}/version.txt)
    FULL_DOCKER_TAG_NAME="${DOCKER_USER_NAME}/${IMAGE_NAME}"	
	
	IMAGE_FOUND="$(findImage ${FULL_DOCKER_TAG_NAME})"
    IS_FOUND="found"
    if [[ -z "${IMAGE_FOUND}" ]]; then
        IS_FOUND="not found"        
    fi
    echo "Docker image '${DOCKER_USER_NAME}/${IMAGE_NAME}' is ${IS_FOUND} in the local repository"

    docker tag ${IMAGE_FOUND} ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION}
    docker push ${FULL_DOCKER_TAG_NAME}
}

pushImageToHub() {
	askDockerUserNameIfAbsent
	setVariables

	echo "Pushing image ${FULL_DOCKER_TAG_NAME}:${IMAGE_VERSION} to Docker Hub"; echo ""

	docker login --username=${DOCKER_USER_NAME}
	pushImage base java-base
	pushImage ${1:-java}
}

cleanup() {
	containersToRemove=$(docker ps --quiet --filter "status=exited")
	[ ! -z "${containersToRemove}" ] && \
	    echo "Remove any stopped container from the local registry" && \
	    docker rm ${containersToRemove} || true

	imagesToRemove=$(docker images --quiet --filter "dangling=true")
	[ ! -z "${imagesToRemove}" ] && \
	    echo "Remove any dangling images from the local registry" && \
	    docker rmi -f ${imagesToRemove} || true
}

showUsageText() {
    cat << HEREDOC

       Usage: $0 --dockerUserName [Docker user name]
                                 --language [language id]
                                 --detach
                                 --jdk [GRAALVM]
                                 --javaopts [java opt arguments]
                                 --cleanup
                                 --buildImage
                                 --runContainer
                                 --pushImageToHub
                                 --help

       --dockerUserName      your Docker user name as on Docker Hub
                             (mandatory with build, run and push commands)
       --language            language id as in java, clojure, scala, etc...
       --detach              run container and detach from it,
                             return control to console
       --jdk                 name of the JDK to use (currently supports
                             GRAALVM only, default is blank which
                             enables the traditional JDK)
       --javaopts            sets the JAVA_OPTS environment variable
                             inside the container as it starts
       --cleanup             (command action) remove exited containers and
                             dangling images from the local repository
       --buildImage          (command action) build the docker image
       --runContainer        (command action) run the docker image as a docker container
       --pushImageToHub      (command action) push the docker image built to Docker Hub
       --help                shows the script usage help text

HEREDOC

	exit 1
}

askDockerUserNameIfAbsent() {
	if [[ -z ${DOCKER_USER_NAME:-""} ]]; then
	  read -p "Enter Docker username (must exist on Docker Hub): " DOCKER_USER_NAME
	fi	
}

setVariables() {
	### Build base image
	BASE_IMAGE_NAME=${BASE_IMAGE_NAME:-nlp-java-base}
	BASE_IMAGE_VERSION=${BASE_IMAGE_VERSION:-$(cat images/base/version.txt)}
	BASE_FULL_DOCKER_TAG_NAME="${DOCKER_USER_NAME}/${BASE_IMAGE_NAME}"

	### Build language specific image
	language_id=${language_id:-java}
	IMAGE_NAME=${IMAGE_NAME:-nlp-${language_id}}
	IMAGE_VERSION=${IMAGE_VERSION:-$(cat images/${language_id}/version.txt)}
	FULL_DOCKER_TAG_NAME="${DOCKER_USER_NAME}/${IMAGE_NAME}"
}

#### Start of script
SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="${SCRIPT_CURRENT_DIR}/images"

BASE_FULL_DOCKER_TAG_NAME=""
FULL_DOCKER_TAG_NAME=""
DOCKER_USER_NAME="${DOCKER_USER_NAME:-neomatrix369}"

CONTAINER_USER=nlp-java
CONTAINER_GROUP=nlp-java
WORKDIR=/home/${CONTAINER_USER}
JDK_TO_USE=""

INTERACTIVE_MODE="--interactive --tty"
TIME_IT="time"

HOST_PORT=8888
CONTAINER_PORT=8888

if [[ "$#" -eq 0 ]]; then
	echo "No parameter has been passed. Please see usage below:"
	showUsageText
fi

while [[ "$#" -gt 0 ]]; do case $1 in
  --help)                showUsageText;
                         exit 0;;
  --cleanup)             cleanup;
                         exit 0;;
  --dockerUserName)      DOCKER_USER_NAME="${2:-}";
                         shift;;
  --language)            language_id=${3:-java};
                         shift;;
  --detach)              INTERACTIVE_MODE="--detach";
                         TIME_IT="";;
  --jdk)                 JDK_TO_USE="${2:-}";
                         shift;;
  --javaopts)            JAVA_OPTS="${2:-}";
                         shift;;
  --buildImage)          buildImage;
                         exit 0;;
  --runContainer)        runContainer;
                         exit 0;;
  --pushImageToHub)      pushImageToHub;
                         exit 0;;
  *) echo "Unknown parameter passed: $1";
     showUsageText;
esac; shift; done

if [[ "$#" -eq 0 ]]; then
	echo "No command action passed in as parameter. Please see usage below:"
	showUsageText
fi