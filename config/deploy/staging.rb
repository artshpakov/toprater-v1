set :branch, "master"

set :domain, "dev.solverclub.com"
server domain, :web, :app, :db, primary: true
