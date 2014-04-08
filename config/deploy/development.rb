set :branch, %x{ git symbolic-ref HEAD 2>/dev/null }.chomp.sub("refs/heads/", '') rescue :development

set :domain, "dev.solverclub.com"
server domain, :web, :app, :db, primary: true
