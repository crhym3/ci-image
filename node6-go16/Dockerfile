FROM node:6
MAINTAINER alex@cloudware.io

# Base
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CHROME_DEB=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

RUN apt-get update -qq && \
	apt-get install -qqy locales && localedef -i en_US -f UTF-8 en_US.UTF-8 && \
	apt-get install -y \
		zip unzip bzip2 ca-certificates curl python-pip gcc libc6-dev make man \
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
	/gcloud/bin/gcloud components update alpha beta -q && \
	rm -f /gcloud.tar.gz

# Go
ENV GOLANG_VERSION 1.6.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 cdde5e08530c0579255d6153b08fdb3b8e47caabbe717bc7bcd7561275a87aeb
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz && \
	echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - && \
	tar -C /usr/local -xzf golang.tar.gz && \
	rm golang.tar.gz

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
ENV NPM_CONFIG_LOGLEVEL=error
RUN npm install -q -g gulp bower

# Workspace
RUN mkdir -p /go/src
ENV GOPATH=/go \
    PATH=/go/bin:/usr/local/go/bin:/gcloud/bin:$PATH
WORKDIR /go
