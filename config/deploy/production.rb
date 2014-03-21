set :branch, "master"

set :domain, "162.243.88.75"
server domain, :web, :app, :db, primary: true
