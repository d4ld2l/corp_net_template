FROM ruby:2.4.1
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y postgresql-client nodejs --no-install-recommends nano nfs-kernel-server nfs-common && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ADD . /usr/src/app
COPY Gemfile Gemfile
ADD ./docker/start.sh /usr/src/app/start.sh

EXPOSE 3000

RUN bin/bundle config git.allow_insecure true
RUN bin/bundle install