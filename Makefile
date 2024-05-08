# vim: ft=make
# vim: tabstop=8
# vim: shiftwidth=8
# vim: noexpandtab

# grep '^[a-z\-]*:' Makefile | cut -d: -f 1 | tr '\n' ' '
.PHONY:	 help  shellcheck shdoc

white           := \033[0;30m
red             := \033[0;31m
yellow          := \033[0;33m
purple          := \033[0;35m
blue            := \033[0;32m
clear           := \033[0m


bg_red		:= \033[7;31m
bg_blue         := \033[7;32m
bg_purple       := \033[7;35m

RUBY_VERSION    := $(cat .ruby-version)
NODE_VERSION    := $(cat .nvmrc | tr -d 'v')
OS	 	:= $(shell uname -s | tr '[:upper:]' '[:lower:]')

# see: https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile/18137056#18137056
SCREEN_WIDTH	:= 100
MAKEFILE_PATH 	:= $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR 	:= $(shell ( cd .; pwd -P ) )
BASHMATIC_HOME  := $(shell echo $(CURRENT_DIR)/dev/bashmatic)
MAKE_ENV	:= .make.env
DEV_DB          := $(shell grep database config/database.yml | grep development | awk '{print $$2}' | sed 's/^$$/ticketing_app_development/g')

help:	   	## Prints help message auto-generated from the comments.
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

reset:		## Complete reset of the databases and runs the rspec and rubocop
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Dropping local databases...$(clear)\n"
		@bundle exec rake db:drop:all
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Creating local databases...$(clear)\n"
		@bundle exec rake db:create:all
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Migrating development...$(clear)\n"
		@bundle exec rake db:migrate
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Seeding development...$(clear)\n"
		@bundle exec rake db:seed
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Cloning to test DB...$(clear)\n"
		@bundle exec rake db:test:prepare
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(bg_blue)$(yellow)Running RSpec...$(clear)\n"
		@bundle exec rspec
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(bg_blue)$(yellow)Running Rubocop...$(clear)\n"
		@bundle exec rubocop


development: 	## Set RAILS_ENV=development
		@echo 'export RAILS_ENV=development' > $(MAKE_ENV)

staging: 	## Set RAILS_ENV=staging
		@echo 'export RAILS_ENV=staging' > $(MAKE_ENV)

production: 	## Set RAILS_ENV=production
		@echo 'export RAILS_ENV=production' > $(MAKE_ENV)

setup: 		## Boots Rails sserver in the whatever RAILS_ENV is set to — eg: make production boot
		bash bin/boot-up

docker-image:	## Builds a docker image named 'tickets'
		docker build -t tickets .

shellcheck:	## Run shellcheck on the shell files
		$(CURRENT_DIR)/bin/shchk

dev-install:    ## Optional install of VIM configuration and other dev tools
		$(CURRENT_DIR)/development/dev-install

# Rails Commands Macros

db-drop:  	## Drop current databases
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Dropping dev database [$(DEV_DB)]$(clear)\n"
		@dropdb $(DEV_DB) || true

db-create:  	node_modules ## Create if necessary, migrate and seed the database
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Creating Database:    [$(DEV_DB)]$(clear)\n"
		@bin/rails db:create
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Migrating Databases:  [$(DEV_DB)]$(clear)\n"
		@bin/rails db:migrate
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Seeding dev database: [$(DEV_DB)]$(clear)\n"
		@bin/rails db:seed

rebuild-dev-db: db-drop development db-create ## Rebuild and re-seed the dev database

node_modules: 	## Install all Node Modules
		@yarn install

assets:    	node_modules ## Build JS & CSS assets
		@yarn run build
		@yarn run build:css

gems: 		## Runs bundle install
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Running bundle install...$(clear)\n"
		bundle install -j 4

foreman: 	## Start Foreman using Procfile.dev
		@printf "\n$(bg_purple)  👉  $(purple)$(clear)  $(yellow)Starting up Foreman in ENV=[$(MAKE_ENV)], db=[$(DEV_DB)]$(clear)\n"
		@bash -c "source $(MAKE_ENV); foreman start -f Procfile.dev"

dev:          	gems node_modules db-create foreman ## Start the development environment, but run yarn install and db-create


ci: 		## Run all tests and linters as if on CI
		bin/rails db:migrate
		bin/rails db:test:prepare
		bundle exec rspec
		bundle exec rubocop
		bin/shchk

prod:           node_modules gems ## Build production assets and start in prod mode
		RAILS_ENV=production bundle exec rake assets:precompile
		RAILS_ENV=production bundle exec rails s


