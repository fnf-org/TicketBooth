FROM docker.io/ruby:2.6-bullseye

# Needed by Ruby to process UTF8-encoded files
ENV LANG C.UTF-8

RUN set -eus; \
    apt-get update -qq; \
    apt-get install -y --no-install-recommends \
    git-all \
    nodejs \
    shared-mime-info \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libjemalloc2 \
    postgresql-client \
    iputils-ping \
    net-tools \
    netcat \
    htop \
    strace \
    pg-activity \
    ; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*;

# @see https://engineering.binti.com/jemalloc-with-ruby-and-docker/
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

WORKDIR /app
COPY Gemfile Gemfile.lock ./
ENV RAILS_ENV="${RAIL_ENV:-"production"}"
RUN gem update --system -N
RUN gem install bundler -N --version 1.17.3
RUN bundle install -j 12 --deployment --without "test development"

COPY . /app

RUN SECRET_KEY_BASE=1 bundle exec rake assets:precompile

EXPOSE 3000
CMD "./entrypoint.sh"
