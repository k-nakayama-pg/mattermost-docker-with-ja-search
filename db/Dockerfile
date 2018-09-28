FROM postgres:9.6.4

WORKDIR /root

COPY mecab-0.996.tar.gz /root
COPY mecab-ipadic-2.7.0-20070801.tar.gz /root
COPY textsearch_ja-textsearch_ja-9.6.0.tar.gz /root

# Install build tools
RUN apt-get update \
    && apt-get install -y build-essential postgresql-server-dev-${PG_MAJOR}

# Install MeCab
RUN tar zxf mecab-0.996.tar.gz \
    && cd mecab-0.996 \
    && ./configure --enable-utf8-only --with-charset=utf8 \
    && make \
    && make install

# Install IPADIC
RUN tar zxf mecab-ipadic-2.7.0-20070801.tar.gz \
    && cd mecab-ipadic-2.7.0-20070801 \
    && echo /usr/local/lib >> /etc/ld.so.conf \
    && ldconfig \
    && ./configure --with-charset=utf8 \
    && make \
    && make install

# Install textsearch_ja
RUN tar zxf textsearch_ja-textsearch_ja-9.6.0.tar.gz \
    && cd textsearch_ja-textsearch_ja-9.6.0 \
    && make \
    && make install

COPY docker-entrypoint-initdb.d/init-extension-db.sh /docker-entrypoint-initdb.d/