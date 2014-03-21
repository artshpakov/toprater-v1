# -*- coding: utf-8 -*-
require 'bundler/capistrano'
# require 'whenever/capistrano'
require 'rvm/capistrano'
# require 'thinking_sphinx/capistrano'
require 'capistrano-unicorn'

set :stages, %w(production staging jenkins)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "AlternativesPower"
set :scm, :git
set :repository,  "ssh://git@github.com/Solver-Club/AlternativesPower.git"
ssh_options[:auth_methods] = %w(publickey password)
# ssh_options[:forward_agent] = true
default_run_options[:pty] = true
set :scm_verbose, true

set :deploy_via, :remote_cache
# set :whenever_command, "bundle exec whenever"

set :rails_env, 'production'

set :rvm_ruby_string, 'ruby-2.1'
set :rvm_type, :user
set :use_sudo, false

set :user, "www-ruby"
set :deploy_to, "/var/www/#{application}"

set :symlinks, ["config/database.yml", "config/unicorn/#{rails_env}.rb", "config/voltdb.yml"]
set :dir_symlinks, %w(db/voltdb log)

after "deploy:update_code", "deploy:migrate"
#after "deploy:update_code", "deploy:build_missing_paperclip_styles"

after 'deploy:update_code' do
  run "rm -f #{current_release}/config/database.yml"
  run "ln -s #{deploy_to}/shared/config/database.yml #{current_release}/config/database.yml"
end

after "deploy:finalize_update", "deploy:make_symlinks:"
after 'deploy:restart', 'unicorn:reload'    # app IS NOT preloaded
after 'deploy:restart', 'unicorn:restart'   # app preloaded
after 'deploy:restart', 'unicorn:duplicate' # before_fork hook implemented (zero downtime deployments)

namespace :deploy do
  after 'update_code', :roles => :app do
    run "rm -f #{current_release}/config/database.yml"
    run "ln -s #{deploy_to}/shared/config/database.yml #{current_release}/config/database.yml"
  end

  desc "Creates additional symlinks for the shared configs."
  task :make_symlinks, :roles => :app, :except => { :no_release => true } do
    fetch(:dir_symlinks, []).each do |path|
      run "mkdir -p #{shared_path}/#{path}"
      run "rm -rf #{release_path}/#{path} && ln -nfs #{shared_path}/#{path} #{release_path}/#{path}"
    end

    fetch(:symlinks, []).map do |path|
      run "mkdir -p #{shared_path}/#{path.gsub(/([^\/]*)$/, '')}"
      run "if [ -f #{release_path}/#{path}.example ]; then yes n | cp -i #{release_path}/#{path}.example #{shared_path}/#{path}; fi;"
      run "rm -rf #{release_path}/#{path} && ln -nfs #{shared_path}/#{path} #{release_path}/#{path}"
    end

    %w(pids sockets).each do |dir|
      run "mkdir -p #{shared_path}/#{dir}"
      run "rm -rf #{release_path}/tmp/#{dir} && ln -nfs #{shared_path}/#{dir} #{release_path}/tmp/#{dir}"
    end
  end

  #desc "build missing paperclip styles"
  #task :build_missing_paperclip_styles, :roles => :app do
    #run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake paperclip:refresh:missing_styles"
  #end
end

namespace :admin do
  desc "Tail production log files."
  task :tail_logs, :roles => :app do
    invoke_command "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts "#{channel[:host]}: #{data}" if stream == :out
      warn "[err :: #{channel[:server]}] #{data}" if stream == :err
    end
  end
end
