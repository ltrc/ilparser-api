FROM            ubuntu:latest
#ENV            HTTP_PROXY      http://proxyuser:proxypwd@proxy.server.com:8080
#ENV            http_proxy      http://proxyuser:proxypwd@proxy.server.com:8080
RUN             apt-get update && apt-get install -y \
                    autoconf \
                    cpanminus \
                    gcc \
                    git \
                    libgdbm-dev \
                    libglib2.0-dev \
                    make \
                    python-numpy \
                    python-pydot \
                    python-urllib3 \
                    python-pip \
                    && rm -rf /var/lib/apt/lists/*
#RUN            git config --global http.proxy http://proxyuser:proxypwd@proxy.server.com:8080
RUN             cpanm \
                    Data::Dumper \
                    Dir::Self \
                    IPC::Run \
                    List::Util \
                    Config::IniFiles \
                    Mojolicious::Lite
RUN             curl -L https://github.com/ltrc/ilparser-api/releases/download/0.1/CRF.-0.58.tar.gz | tar -xz \
                    && cd CRF++-0.58 && ./configure && make install \
                    && echo "/usr/local" > /etc/ld.so.conf.d/crfpp.conf && ldconfig \
                    && cd -
RUN             git clone https://github.com/ltrc/ilparser-api.git && cd ilparser-api && ./setup.sh
RUN             echo '#!/bin/bash\ncd /ilparser-api && perl api.pl $@' >> /entrypoint.sh && chmod a+x /entrypoint.sh
ENTRYPOINT      ["/entrypoint.sh"]
CMD             ["prefork", "-m production -l http://*:80"]
