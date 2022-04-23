#!/bin/bash

set -e

if [[ -z $RAILS_ENV ]]; then
  echo "Please set RAILS_ENV before invoking this script."
  exit 1
fi

# Discourse Settings to optimize Garbage Collection
export RUBY_GC_HEAP_INIT_SLOTS=997339
export RUBY_GC_HEAP_FREE_SLOTS=626600
export RUBY_GC_HEAP_GROWTH_FACTOR=1.03
export RUBY_GC_HEAP_GROWTH_MAX_SLOTS=88792
export RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=2.4
export RUBY_GC_MALLOC_LIMIT=34393793
export RUBY_GC_MALLOC_LIMIT_MAX=41272552
export RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.32
export RUBY_GC_OLDMALLOC_LIMIT=39339204
export RUBY_GC_OLDMALLOC_LIMIT_MAX=47207045
export RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=1.2

# https://www.mikeperham.com/2018/04/25/taming-rails-memory-bloat/
export MALLOC_ARENA_MAX=2

if [[ ${RAILS_ENV} == "production" ]]; then
  export DATABASE_URL="postgres://${TICKET_DB_USER}:${TICKET_DB_PASSWORD}@${TICKET_DB_HOST}:${TICKET_DB_PORT}/${TICKET_DB_NAME}?"
fi
# This may be a problem if we run more than one pod
# possible solution — adds an arbitrary delay before running it
# delay="$(( RANDOM / 500 ))" ; sleep ${delay} && bundle exec rake db:migrate
bundle exec rake db:migrate

if [[ "$DB_SEED" = "true" ]]; then
  echo "seeding the DB"
  bundle exec rake db:seed
fi

bundle exec puma -C config/puma.rb
