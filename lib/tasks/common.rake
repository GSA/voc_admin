desc "drop, create, migrate and seed the DB"
task :recreate_dev =>['db:drop', 'db:create', 'db:migrate', 'db:seed', 'db:test:prepare' ]
