FROM buildpack-deps
MAINTAINER alex@cloudware.io

# Base
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CHROME_DEB=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex && \
  for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done
RUN apt-get update -qq && \
	apt-get install -qqy locales && localedef -i en_US -f UTF-8 en_US.UTF-8 && \
	apt-get install -y \
		zip unzip ca-certificates curl python-pip gcc libc6-dev make man \
		bzr git mercurial \
		openjdk-7-jdk \
		xvfb xauth libnss3 libgconf2-4 libxi6 libatk1.0-0 libxcursor1 libxss1 libxcomposite1 libasound2 \
		libxtst6 libxrandr2 libgtk2.0-0 libgdk-pixbuf2.0-0 \
		libpango1.0-0 libappindicator1 xdg-utils fonts-liberation \
		--no-install-recommends && \
	pip install docker-py && \
	curl -sSLo /tmp/chrome.deb $CHROME_DEB && \
	dpkg -i /tmp/chrome.deb && rm /tmp/chrome.deb


# Google Cloud
ENV CLOUDSDK_CORE_DISABLE_PROMPTS=1 \
    CLOUDSDK_PYTHON_SITEPACKAGES=1
ADD https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz /gcloud.tar.gz
RUN mkdir /gcloud && \
	tar -xzf /gcloud.tar.gz --strip 1 -C /gcloud && \
	/gcloud/install.sh && \
	/gcloud/bin/gcloud components update app -q && \
	rm -f /gcloud.tar.gz

# Go
ENV GOLANG_VERSION=1.5.1 \
    GOLANG_SHA1=46eecd290d8803887dec718c691cc243f2175fe0
RUN curl -fsSL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
	echo "$GOLANG_SHA1  /tmp/go.tar.gz" | sha1sum -c - && \
	tar -C /usr/local -xzf /tmp/go.tar.gz && \
	rm /tmp/go.tar.gz

# Node.js
ENV NODE_VERSION=0.12.8 NPM_VERSION=3.4.1
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" && \
	curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
	gpg --verify SHASUMS256.txt.asc && \
	grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - && \
	tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
	rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc && \
	npm install -q -g npm@"$NPM_VERSION" && \
	npm cache clear && \
	npm install -q -g gulp bower

# Ruby with rbenv
ENV RUBY_VERSION=2.2.0 \
    PATH=/rbenv/bin:$PATH
RUN git clone https://github.com/rbenv/rbenv.git /rbenv && \
	git clone https://github.com/rbenv/ruby-build.git /rbenv/plugins/ruby-build && \
	/rbenv/plugins/ruby-build/install.sh && \
	eval "$(rbenv init -)" && \
	rbenv install 2.2.0 && \
	rbenv global 2.2.0 && \
	echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc && \
	gem install bundler

# Other tools
RUN git clone https://github.com/sass/libsass.git && \
	git clone https://github.com/sass/sassc.git && \
	cd sassc && export SASS_LIBSASS_PATH=../libsass && \
	make install && \
	cd .. && rm -rf libsass sassc

# Workspace
RUN mkdir -p /go/src
ENV GOPATH=/go \
    PATH=/go/bin:/usr/local/go/bin:/gcloud/bin:$PATH
WORKDIR /go
