set :repository, "."
set :scm, :git
set :branch, "master"

server "localhost", :web, :db, :app, primary: true, local: true
