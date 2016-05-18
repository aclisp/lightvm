FROM 61.160.36.122:8080/lightvm:latest

# Install redis tools
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r redis && useradd -r -g redis redis

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		ruby \
	&& rm -rf /var/lib/apt/lists/*

ENV REDIS_VERSION 3.0.6
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.6.tar.gz
ENV REDIS_DOWNLOAD_SHA1 4b1c7b1201984bca8f7f9c6c58862f6928cf0a25

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN buildDeps='gcc libc6-dev make' \
	&& set -x \
	&& DEBIAN_FRONTEND=noninteractive apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/redis \
	&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
	&& echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
	&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
	&& rm redis.tar.gz \
	&& make -C /usr/src/redis \
	&& make -C /usr/src/redis install \
	&& make -C /usr/src/redis distclean \
	&& DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove $buildDeps

# for ruby gem.
RUN gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/ --remove http://rubygems.org/ \
    && gem install redis

# Clean up APT when done.
RUN DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
