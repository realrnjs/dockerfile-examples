FROM dockerfile/jdk-oracle

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV ELASTICSEARCH_VERSION 1.6.0

# Elasticsearch
RUN \
    apt-key adv --keyserver pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4 && \
    if ! grep "elasticsearch" /etc/apt/sources.list; then echo "deb http://packages.elasticsearch.org/elasticsearch/${ELASTICSEARCH_VERSION%.*}/debian stable main" >> /etc/apt/sources.list;fi && \
    apt-get update

RUN \
    apt-get install -y automake && \
    apt-get install -y elasticsearch && \
    apt-get clean

#PATH and copy config
COPY config /usr/share/elasticsearch/config

RUN \
  /usr/share/elasticsearch/bin/plugin -i mobz/elasticsearch-head && \
  /usr/share/elasticsearch/bin/plugin -i lukas-vlcek/bigdesk && \
  /usr/share/elasticsearch/bin/plugin -i lmenezes/elasticsearch-kopf

#한글 형태소 plugin
RUN \
  cd /opt &&\
  wget https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz &&\
  tar xvf mecab-0.996-ko-0.9.2.tar.gz &&\
  cd /opt/mecab-0.996-ko-0.9.2 &&\
  ./configure &&\
  make &&\
  make check &&\
  make install &&\
  ldconfig

RUN \
  cd /opt &&\
  wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.1-20150707.tar.gz &&\
  tar xvf mecab-ko-dic-2.0.1-20150707.tar.gz

RUN \
  cd /opt/mecab-ko-dic-2.0.1-20150707 &&\
  ./autogen.sh &&\
  ./configure &&\
  make &&\
  make install

ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8

RUN \
  cd /opt &&\
  wget https://mecab.googlecode.com/files/mecab-java-0.996.tar.gz &&\
  tar xvf mecab-java-0.996.tar.gz &&\
  cd /opt/mecab-java-0.996 &&\
  sed -i 's|/usr/lib/jvm/java-6-openjdk/include|/usr/lib/jvm/java-8-oracle/include|' Makefile &&\
  make &&\
  cp libMeCab.so /usr/local/lib

# Define mountable directories.
VOLUME ["/data"]

RUN /usr/share/elasticsearch/bin/plugin --install analysis-mecab-ko-0.17.0 --url https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-0.17.0.zip

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300

# Define default command.
CMD ["/usr/share/elasticsearch/bin/elasticsearch", "-Djava.library.path=/usr/local/lib"]
