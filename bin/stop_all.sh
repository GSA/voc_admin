#!/bin/sh

# Stop all databases required for project

bin_path=$( cd $(dirname $0) ; pwd -P )

echo $( ${bin_path}/mongod.sh stop )
echo $( ${bin_path}/redis.sh stop )

bundle exec rake resque:stop_workers
echo "Successfully stopped resque workers."
