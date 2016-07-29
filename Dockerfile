FROM robwdux/alpine-init:1.18.1.3

MAINTAINER rob dux <robwdux@gmail.com>

WORKDIR /app

CMD ["/usr/bin/node"]

ARG NODE_VERSION=${NODE_VERSION:-6.2.2}

ENV CONFIG="\
      --prefix=/usr \
      --shared-zlib \
      --shared-libuv \
      --shared-openssl \
    "

# https://github.com/alpinelinux/aports/blob/master/main/nodejs/APKBUILD
RUN set -o nounset -o errexit -o xtrace -o verbose \
    && apk add --no-cache --virtual .buildDeps \
          make \
          gcc \
          g++ \
          python \
          linux-headers \
          openssl-dev \
          zlib-dev \
          libuv-dev \
          paxmark \
          binutils-gold \
          gnupg \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
          9554F04D7259F04124DE6B476D5A82AC7E37093B \
          94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
          0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
          FD3A5288F042B6850C66B31F09FE44734EB7990E \
          71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
          DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
          C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
          B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    && mkdir /usr/src && cd /usr/src \
    && curl -fLO https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz \
    && curl -fLO https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc \
    && gpg --verify SHASUMS256.txt.asc \
    && grep node-v${NODE_VERSION}.tar.gz SHASUMS256.txt.asc | sha256sum -c - \
    && tar -zxf node-v${NODE_VERSION}.tar.gz && cd node-v${NODE_VERSION} \
    && ./configure $CONFIG \
    && make -j"$(getconf _NPROCESSORS_ONLN)" -C out mksnapshot BUILDTYPE=Release \
    && paxmark -m out/Release/mksnapshot \
    && make -j"$(getconf _NPROCESSORS_ONLN)" \
    && make install \
    # don't enforce memory protect so JIT works
    && paxmark -m /usr/bin/node \
    # does our compiled node work?
    && node -e "console.log('Hello from Node.js ' + process.version)" \
		# purge
    && apk del --purge .buildDeps \
    && cd; rm -rf /usr/src /root/* /tmp/* \
	  && for d in doc html man; do rm -vr /usr/lib/node_modules/npm/$d; done \
    && runDeps="$( \
          scanelf --needed --nobanner /usr/bin/node \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --no-cache $runDeps libuv libstdc++ libgcc

# COMMIT - git show -s --format=%H
# DATE - git show -s --format=%cI
# AUTHOR - git show -s --format='"%an" <%ae>'
# URL - git ls-remote --get-url | sed -e "s|:|/|" -e s|git@|https://|"
ARG GIT_COMMIT=""
ARG GIT_COMMIT_DATE=""
ARG GIT_COMMIT_AUTHOR=""
ARG GIT_REPO_URL=""
