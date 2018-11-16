FROM ruby:2.5.1
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y postgresql-client nodejs nano nfs-kernel-server nfs-common cups-pdf libreoffice libreoffice-writer imagemagick-6.q16 libmagick++-6.q16-dev libmagickcore-dev libmagickwand-dev gsfonts ghostscript --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ADD . /usr/src/app
COPY Gemfile Gemfile
ADD ./docker/start.sh /usr/src/app/start.sh

EXPOSE 3000

RUN bin/bundle config git.allow_insecure true
RUN bin/bundle install