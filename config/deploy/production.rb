# frozen_string_literal: true

set :ruby_version, File.read('.ruby-version')
set :node_version, '18'
set :yarn_version, File.read('.yarn-version')

set :target_os, 'linux'
set :rails_env, 'production'

require_relative '../../capistrano/loader/os'

server 'tickets.fnf.events', roles: %w[app db web], user: 'fnf', sudo: true
set :gem_config, {}

set :slack_channel, ['#notifications-prod']
set :slack_username, 'DeployBot'
set :slack_emoji, ':trollface:'
set :slack_user, `git config user.name || echo $USER`
set :slack_fields, %w[status stage branch revision hosts]
set :slack_mrkdwn_in, %w[pretext text fields]
set :slack_hosts, -> { release_roles(:all).map(&:hostname).join("\n") }
set :slack_text, lambda {
  elapsed = Integer(fetch(:time_finished) - fetch(:time_started))
  "Revision #{fetch(:current_revision, fetch(:branch))} of " \
    "#{fetch(:application)} deployed to #{fetch(:stage)} by #{fetch(:slack_user)} " \
    "in #{elapsed} seconds."
}
set :slack_deploy_starting_text, lambda {
  "#{fetch(:stage)} deploy starting with revision/branch #{fetch(:current_revision, fetch(:branch))} for #{fetch(:application)}"
}
set :slack_deploy_failed_text, lambda {
  "#{fetch(:stage)} deploy of #{fetch(:application)} with revision/branch #{fetch(:current_revision, fetch(:branch))} failed"
}
set :slack_deploy_finished_color, 'good'
set :slack_deploy_failed_color, 'danger'
set :slack_notify_events, %i[started finished failed]
