#!/bin/bash

RAILS_ENV=production BUNDLE_WITHOUT=development:test BUNDLE_GEMFILE=Gemfile GEM_HOME=gems java -classpath "lib/*" org.jruby.Main -S rake resque:start_workers

exit
