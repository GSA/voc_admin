#!/usr/bin/env bash
./wait-for-it.sh -t 0 elasticsearch:9200 -- bundle && bundle exec rake db:create db:migrate && bundle exec rake db:seed && bundle exec rails s --port 80 --binding '0.0.0.0'
