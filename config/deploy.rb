# This is a standard multistage deployment recipe, able to handle staging, migrating and rolling back as required.
require "bundler/capistrano"
require "rvm/capistrano"
# require "delayed/recipes"

ssh_options[:keys] = ["/Users/will/.ssh/bloodnok.pem"]
set :user, 'spanner'
set :group, 'spanner'

# This is the basic setup. Roles, branches and destinations are set in deploy/[stage].rb
set :application, "proc"
set :deploy_to, "/var/www/#{application}"
set :rails_env, "production"
set :branch, 'master'
role :web, "bloodnok.spanner.org"
role :app, "bloodnok.spanner.org"
role :db, "bloodnok.spanner.org", :primary => true
set :keep_releases, 2

# RVM on the server gives us a known (recent) ruby version.
set :rvm_type, :system 
set :rvm_ruby_string, '1.9.3'

# RVM on the server gives us a known (recent) ruby version.
set :scm, :git
set :repository, "git@github.com:spanner/processional.git"
set :use_sudo, false

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

# We are maintaining a local repository cache (on the server) to speed up incremental deployments.
set :deploy_via, :remote_cache

# These are the standard passenger hooks. There is no stop.
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :filing do
  task :create_symlinks, :roles => :app do
    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml" 
  end
end
# 
before "deploy:assets:precompile", "filing:create_symlinks"
before "deploy:assets:precompile", "deploy:migrate"
after "deploy:update", "deploy:cleanup"
