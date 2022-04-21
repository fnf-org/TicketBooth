ARG ruby_version
FROM ruby:2.5.8

# Needed by Ruby to process UTF8-encoded files
ENV LANG C.UTF-8

RUN set -eus; \
    apt-get update -qq; \
    apt-get install -y \
    nodejs \
    shared-mime-info \
    build-essential \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    ruby-yaml-db \
    postgresql-client \
    ; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*;

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . /app

RUN SECRET_KEY_BASE=1 bundle exec rake assets:precompile

EXPOSE 3000
CMD "./entrypoint.sh"
