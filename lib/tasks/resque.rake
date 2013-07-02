# loads all rake task of resque
require 'resque/tasks'

# following statement is required only if your background task needs rails enviroment else skip it
task "resque:setup" => :environment
