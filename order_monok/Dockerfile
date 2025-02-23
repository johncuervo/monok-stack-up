ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION-slim AS base

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libyaml-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

ENTRYPOINT ["/app/bin/docker-entrypoint"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]