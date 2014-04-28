set :branch, "master"

set :domain, "188.226.212.228" # sentimeta.com
server domain, :web, :app, :db, primary: true
