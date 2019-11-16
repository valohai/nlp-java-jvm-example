FROM valohai/jupyhai as base-image

### Install JDK 9 from AdoptOpenJDK images

COPY --from=adoptopenjdk/openjdk9 /opt/java /opt/java

### Install curl needed for rest of the tasks

USER root
RUN apt-get update && apt-get install -qy curl

ARG WORKDIR
WORKDIR ${WORKDIR}

### Java setup

ARG JAVA_9_HOME
ENV JAVA_HOME=${JAVA_9_HOME}
ENV PATH=${JAVA_HOME}/bin:${PATH}

### Test Java

RUN ${JAVA_9_HOME}/bin/java -version

### Install packages

RUN apt-get update && apt-get install -qy unzip git vim

RUN unzip -version
RUN git --version
RUN vim --version

### Install the Jupyter Java Kernel

COPY install-java-kernel.sh /install-java-kernel.sh
RUN cd / && ./install-java-kernel.sh

### Setup user
COPY .bashrc .bashrc_custom
RUN cat .bashrc_custom >> /home/jovyan/.bashrc
RUN rm .bashrc_custom