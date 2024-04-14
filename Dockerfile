# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.3

FROM docker.io/ruby:${RUBY_VERSION}-bookworm

ENV LANG C.UTF-8

RUN set -eus; \
    apt-get update -qq; \
    apt-get install -y --no-install-recommends \
    build-essential \
    git-all \
    htop \
    iputils-ping \
    libjemalloc2 \
    libpq-dev \
    libvips \
    libxml2-dev \
    libxslt1-dev \
    net-tools \
    node-gyp \
    nodejs \
    pg-activity \
    pkg-config \
    postgresql-client \
    python-is-python3 \
    shared-mime-info \
    strace \
    ; \
    apt-get clean; \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*;

WORKDIR /rails

# @see https://engineering.binti.com/jemalloc-with-ruby-and-docker/

# ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 \
ENV NODE_VERSION=20.12.1 \
    YARN_VERSION=latest \
    PATH=/usr/local/node/bin:$PATH

RUN gem update --system -N

RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node

RUN npm install -g npm@10.5.2 && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Clean up installation packages to reduce image size
RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY "${BUNDLE_PATH}" "${BUNDLE_PATH}"

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

RUN chown -R rails:rails db log storage tmp /rails

USER 1000:1000

EXPOSE 3000

RUN chmod 755 /rails/bin/docker-entrypoint

ENV RAILS_ENV=production

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
