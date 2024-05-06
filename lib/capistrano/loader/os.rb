# frozen_string_literal: true

load "lib/capistrano/tasks/os/#{fetch(:target_os).downcase}.cap"
#
# if fetch(:ruby_version)
#   set :ruby_bin_dir, "#{fetch(:user_home)}/.rbenv/versions/#{fetch(:ruby_version)}/bin"
# else
#   set :ruby_bin_dir, "#{fetch(:user_home)}/.rbenv/shims"
# end
