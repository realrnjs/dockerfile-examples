FROM dockerfile/ubuntu

ENV JAVA_VERSION 8

# Install Java.
RUN \
  echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java${JAVA_VERSION}-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk${JAVA_VERSION}-installer

RUN update-alternatives --display java

# Define commonly used JAVA_HOME variable
#ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSION}-oracle
