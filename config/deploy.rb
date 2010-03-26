set :default_stage, "production"
set :stages, %w(production development)
require 'capistrano/ext/multistage'

set :use_sudo, true
set :application, "WorldHub"
set :repository,  "git@github.com:twilliams/WorldHub.git"

set :scm, :git

ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache

namespace :deploy do

  task :full do
    update_code
    finalize_update
    symlink
    bundler
    migrate
    restart
    cleanup
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end  
  
  task :bundler do
    run "cd #{current_path} && bundle install"
  end 
  
end