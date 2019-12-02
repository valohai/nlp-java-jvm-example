FROM adoptopenjdk/openjdk9

### Install GraalVM
COPY --from=findepi/graalvm /graalvm/ /opt/java/graalvm/

### Install curl needed for rest of the tasks
RUN apt-get update && apt-get install -qy curl

ARG WORKDIR
WORKDIR ${WORKDIR}

### Java setup
ARG JAVA_9_HOME

ARG GRAALVM_HOME
ENV GRAALVM_HOME=${GRAALVM_HOME}
ENV JAVA_HOME=${JAVA_9_HOME}
ENV PATH=${JAVA_HOME}/bin:${PATH}

### Test Java (Traditional and GraalVM)

RUN ${JAVA_9_HOME}/bin/java -version

RUN ${GRAALVM_HOME}/bin/java -version

### Install packages

RUN apt-get update && apt-get install -qy unzip git vim

RUN unzip -version
RUN git --version
RUN vim --version

### Setup user
ARG CONTAINER_GROUP
ARG CONTAINER_USER
RUN groupadd -r ${CONTAINER_GROUP} && useradd -g ${CONTAINER_GROUP} ${CONTAINER_USER}
RUN cd ${WORKDIR}
RUN chown -R ${CONTAINER_USER}:${CONTAINER_GROUP} .

RUN cp /root/.bashrc ${WORKDIR}/.bashrc
COPY .bashrc .bashrc_custom
RUN cat .bashrc_custom >> .bashrc