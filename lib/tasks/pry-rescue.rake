desc 'pry-rescue[buggy:task] to invoke pry on unhandled exception'
task :'pry-rescue', :task do |_, args|
  require 'pry-rescue'
  puts "debugging #{args[:task]}"
  Pry::rescue do
    Rake::Task[args[:task]].invoke
  end
end
