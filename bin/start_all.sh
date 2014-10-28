#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$( dirname "${DIR}" )" && pwd )"

MONGO_CONFIG="${PROJECT_ROOT}/config/mongod.conf"

# Check to make sure MySQL is running
start_mysql() {
  UP=$(pgrep mysql | wc -l);
  if [ "$UP" -ne 1 ]; then
    echo "MySQL is not running";
    mysql.server start
  else
    echo "MySQL is running.";
  fi
}

start_mysql

# Check to make sure that MongoDB is Running
start_mongo() {
  UP=$(pgrep mongodb | wc -l)
  if [ "$UP" -ne 1 ]; then
    echo "MongoDB is not running";
    if [ ${MONGO_CONFIG} -e ]; then
      mongod --config ${MONGO_CONFIG}
    else
      mongod
    fi
  else
    echo "MongoDB is running."
  fi
}

#start_mongo
