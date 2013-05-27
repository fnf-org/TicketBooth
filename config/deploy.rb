set :application           , 'cloudwatch'
set :user                  , application
set :domain                , 'cloudwatch.fm'
set :use_sudo              , false
set :ssh_options           , { forward_agent: true, compression: 'none' }
set :keep_releases         , 20 # Keep the last N releases

# Source code repository
set :repository            , 'git@github.com:sds/cloudwatch.git'
set :branch                , 'master'
set :migrate_target        , :current
set :scm                   , :git
set :git_enable_submodules , 1

set :deploy_via, :remote_cache
set :deploy_to, "/home/#{application}/deploy"

server domain, :app, :web, :db, primary: true

# Technically could break site for a short time, but that's OK for our scale
before 'deploy:restart', 'deploy:migrate'

after 'deploy:update_code', 'deploy:symlink_configs'
namespace :deploy do
  desc 'Symlinks production config files'
  task :symlink_configs, roles: :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/stripe.yml #{release_path}/config/stripe.yml"
  end

  desc 'Zero-downtime restart of Unicorn to load new code'
  task :restart, roles: :app do
    # XXX: There are problems with the zero-downtime deploys. In the interest
    # of having something working, just kill and start the server for now.
    #run "kill -s USR2 `cat #{shared_path}/pids/unicorn.#{application}.pid`"
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.#{application}.pid`"
    run "cd #{current_path} && bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  task :start, roles: :app do
    run "cd #{current_path} && bundle exec unicorn_rails -c config/unicorn.rb -D"
  end

  task :stop, roles: :app do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.#{application}.pid`"
  end
end

# Ensure we have the latest gems before our asset pipeline tries to load them
before 'deploy:assets:precompile', 'bundle:install'
namespace :bundle do
  desc 'Install all gem dependencies'
  task :install, roles: :app do
    run "cd #{release_path} && bundle install --without development test"
  end
end
