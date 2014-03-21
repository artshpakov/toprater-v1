set :repository, "."
set :scm, :none
set :deploy_via, :copy

server "localhost", :web, :db, :app, primary: true, local: true
