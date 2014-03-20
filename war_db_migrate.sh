#!/bin/bash

RAILS_ENV=production BUNDLE_WITHOUT=development:test BUNDLE_GEMFILE=Gemfile GEM_HOME=gems java -classpath "lib/*" org.jruby.Main -S rake db:create db:migrate db:seed db:mongoid:create_indexes

exit
