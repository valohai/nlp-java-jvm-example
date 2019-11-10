FROM valohai/jupyhai as base-image

### Install JDK 8 from AdoptOpenJDK images

COPY --from=adoptopenjdk/openjdk8:jdk8u212-b03 /opt/java /opt/java

### Install curl needed for rest of the tasks

USER root
RUN apt-get update && apt-get install -qy curl

ARG WORKDIR
WORKDIR ${WORKDIR}

### GraalVM installation

ARG GRAALVM_HOME
ENV GRAALVM_HOME=${GRAALVM_HOME}

ARG JAVA_8_HOME
ENV JAVA_8_HOME=${JAVA_8_HOME}
ENV JAVA_HOME=${JAVA_8_HOME}
ENV PATH=${JAVA_HOME}/bin:${PATH}

COPY --from=findepi/graalvm /graalvm/ /opt/java/graalvm/

### Remove unused Java binaries

RUN rm -fr ${GRAALVM_HOME}/languages ${GRAALVM_HOME}/jre/languages 

### Test Java

RUN ${JAVA_8_HOME}/bin/java -version

RUN ${GRAALVM_HOME}/bin/java -version

### Install packages

RUN apt-get update && apt-get install -qy unzip git vim

RUN unzip -version
RUN git --version
RUN vim --version

### Setup user

ARG GROUP
#RUN useradd -g ${GROUP} nlp-java
COPY .bashrc .bashrc_custom
RUN cat .bashrc_custom >> /home/jovyan/.bashrc
RUN rm .bashrc_custom
#RUN cd ${WORKDIR} && chown -R nlp-java:${GROUP} .

#ENV HOME=${WORKDIR}

#ENTRYPOINT [""]
#CMD [""]