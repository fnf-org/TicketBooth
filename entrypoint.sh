#! /bin/sh

set -e

export DATABASE_URL="postgres://${TICKET_DB_USER}:${TICKET_DB_PASSWORD}@${TICKET_DB_HOST}:${TICKET_DB_PORT}/${TICKET_DB_NAME}?"

bundle exec rake db:migrate
if [ "$DB_SEED" = "true" ]; then
  echo "seeding the DB"
  bundle exec rake db:seed
fi

bundle exec rails s -p 3000 -b '0.0.0.0'
