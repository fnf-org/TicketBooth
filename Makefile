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


env: 		
		@echo 'export RUBYOPT="-W0"' 		 > $(MAKE_ENV)
		@echo 'export MALLOC_ARENA_MAX=2' 	>> $(MAKE_ENV)

development: 	env ## Set RAILS_ENV=development
		echo 'export RAILS_ENV=development'	>> $(MAKE_ENV)

staging: 	env ## Set RAILS_ENV=staging
		echo 'export RAILS_ENV=staging'		>> $(MAKE_ENV)

production: 	env ## Set RAILS_ENV=production
		echo 'export RAILS_ENV=production'	>> $(MAKE_ENV)

boot: 		## Boots Rails server in the whatever RAILS_ENV is set to — eg: make production boot
		@bash -c " \
			set -ex; \
			export RUBYOPT=-W0 && \
			if [[ -n $(MAKE_ENV) && -f $(MAKE_ENV) ]] ; then source $(MAKE_ENV) && rm -f $(MAKE_ENV); fi && \
			( bundle check || bundle install; ) && \
			RAILS_ENV=$(RAILS_ENV) bundle exec rake db:migrate && \
			if [[ \"${RAILS_ENV}\" =~ production ]] ; then bundle exec rake assets:precompile; fi && \
			( RAILS_ENV=$(RAILS_ENV) bin/puma & ) "
		@bash -c "sleep 4 && open 'http://127.0.0.1:3000'"


docker-image:	## Builds a docker image named 'tickets'
		docker build -t tickets .

