set :branch, %x{ git symbolic-ref HEAD 2>/dev/null }.chomp.sub("refs/heads/", '') rescue :development

set :domain, "162.243.88.75"
server domain, :web, :app, :db, primary: true
