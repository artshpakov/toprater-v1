set :repository, "."
set :scm, :git
set :branch, "development"

server "localhost", :web, :db, :app, primary: true, local: true
