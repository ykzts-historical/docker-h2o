FROM alpine:3.7

ARG H2O_VERSION=2.2.5
ARG H2O_DOWNLOAD_SHA256=eafb40aa2d93b3de1af472bb046c17b2335c3e5a894462310e1822e126c97d24

RUN addgroup -S h2o \
	&& adduser -D -G h2o -S -s /sbin/nologin h2o \
	&& apk add --no-cache libressl perl \
	&& apk add --no-cache --virtual .build-deps \
		bison \
		build-base \
		ca-certificates \
		cmake \
		libressl-dev \
		ruby \
		zlib-dev \
	&& update-ca-certificates \
	&& mkdir -p /tmp/src \
	&& wget -O h2o.tar.gz https://github.com/h2o/h2o/archive/v$H2O_VERSION.tar.gz \
	&& echo "$H2O_DOWNLOAD_SHA256 *h2o.tar.gz" | sha256sum -c - \
	&& tar -xzf h2o.tar.gz -C /tmp/src \
	&& rm h2o.tar.gz \
	&& cd /tmp/src/h2o-$H2O_VERSION \
	&& cmake -DCMAKE_EXE_LINKER_FLAGS=-static -DWITH_BUNDLED_SSL=off -DWITH_MRUBY=on \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /tmp/src \
	&& rm -rf /usr/local/include \
	&& rm -rf /usr/local/lib \
	&& rm -rf /usr/local/lib64 \
	&& rm -rf /usr/local/share/doc \
	&& cd \
	&& mkdir -p /etc/h2o \
	&& mkdir -p /var/www/html \
	&& apk del .build-deps

COPY h2o.conf /etc/h2o/

EXPOSE 80

CMD ["h2o", "-c", "/etc/h2o/h2o.conf"]
