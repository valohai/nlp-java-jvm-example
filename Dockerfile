FROM adoptopenjdk/openjdk9

WORKDIR /home/nlp-java

### GraalVM installation
ARG GRAALVM_VERSION
ENV GRAALVM_VERSION="${GRAALVM_VERSION}"

RUN curl -O -L -J https://github.com/oracle/graal/releases/download/vm-${GRAALVM_VERSION}/graalvm-ce-linux-amd64-${GRAALVM_VERSION}.tar.gz

RUN tar xzf graalvm-ce-linux-amd64-${GRAALVM_VERSION}.tar.gz -C /opt/java/

ENV GRAALVM_HOME="/opt/java/graalvm-ce-${GRAALVM_VERSION}"

ENV JAVA_HOME=/opt/java/graalvm-ce-${GRAALVM_VERSION}

ENV PATH=${JAVA_HOME}/bin:$PATH

### Remove unused Java binaries

RUN rm graalvm-ce-linux-amd64-${GRAALVM_VERSION}.tar.gz
RUN rm -fr /opt/java/openjdk

### Test Java

RUN java -version

### Install packages
RUN apt-get update && apt-get install unzip

### Setup user

RUN groupadd -r nlp_java && useradd -r -g nlp_java nlp_java
RUN chown -R nlp_java:nlp_java .
USER nlp_java

COPY .bashrc .bashrc

### Stanford NLP installation
### https://stanfordnlp.github.io/CoreNLP/

RUN curl -O -L -J http://nlp.stanford.edu/software/stanford-corenlp-full-2018-10-05.zip
RUN unzip stanford-corenlp-full-2018-10-05.zip
RUN rm stanford-corenlp-full-2018-10-05.zip

### Apache OpenNLP installation
### https://opennlp.apache.org/

RUN curl -O -L -J http://apache.mirror.anlx.net/opennlp/opennlp-1.9.1/apache-opennlp-1.9.1-bin.tar.gz
RUN tar xvzf apache-opennlp-1.9.1-bin.tar.gz
RUN rm apache-opennlp-1.9.1-bin.tar.gz

### NLP4J: NLP Toolkit for JVM Languages
### https://emorynlp.github.io/nlp4j/

RUN curl -O -L -J http://nlp.mathcs.emory.edu/nlp4j/nlp4j-appassembler-1.1.3.tgz
RUN tar xvzf nlp4j-appassembler-1.1.3.tgz
RUN rm nlp4j-appassembler-1.1.3.tgz