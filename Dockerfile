ARG ruby_version
FROM ruby:${ruby_version}

RUN apt-get update -qq && apt-get install -y build-essential

# Postgres
RUN apt-get install -y libpq-dev

# Nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# Needed by Ruby to process UTF8-encoded files
ENV LANG C.UTF-8
