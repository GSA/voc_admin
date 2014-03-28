#!/bin/sh

# Start and stop mongod using the config file in config/mongod.conf

set -e

mongod=$(command -v mongod)
script_dir=$( cd $(dirname $0) ; pwd -P )
config_dir="${script_dir}/../config"
config_file="${config_dir}/mongod.conf"
pid_file="${script_dir}/../tmp/pids/mongod.pid"
data_dir="${script_dir}/../db/mongo_data/"
logfile="${script_dir}/../log/mongod.log"

RETVAL=0

check_for_mongod() {
  if ! command -v ${mongod} > /dev/null 2>&1; then
    echo "Mongo DB is not installed."
    echo "MongoDB is required to run the VOC application."
    exit 1
  fi
}

start() {
  if [[ -e ${pid_file} ]]; then
    echo "MongoDB is already running."
    exit 0
  fi

  if [[ -e ${config_file} ]]; then
    echo "Config file (mongod.conf) found in config directory."
    echo "Starting MongoDB using config file."

    `${mongod} -f $config_file > /dev/null`
    RETVAL=$?

    if [ $RETVAL -gt 0 ]; then
      echo "Error starting MongoDB. Check the log file for more information."
    fi
  else
    echo "MongoDB config file not found in config directory."
    echo "Starting MongoDB using command line arguments."

    # Ensure data directory exists
    if [[ ! -d ${data_dir} ]]; then
      `mkdir -p ${data_dir}`
    fi

    # Ensure pid files directory exists
    if [[ ! -d "${script_dir}/../tmp/pids" ]]; then
      `mkdir -p ${script_dir}/../tmp/pids"`
    fi

    `${mongod} --dbpath ${data_dir} --logpath ${logfile} --pidfilepath ${pid_file} --fork --logappend > /dev/null`
    RETVAL=$?

  fi
}

stop() {
  if [[ -e ${pid_file} ]]; then
    echo "PID file found.  Using PID to stop MongoDB."
    pid=$( cat ${pid_file} )
    `kill -2 ${pid} > /dev/null`
    RETVAL=$?

    if [ $RETVAL -eq 0 ]; then
      # Remote PID file now that server has stopped
      `rm ${pid_file}`
    fi
  else
    echo "No PID file found. Using grep to check for running MongoDB instances"
    grep_mongo=`ps aux | grep -v grep | grep "mongod"`
    if [ ${#grep_mongo} -gt 0 ]; then
      echo "Stop MongoDB."
      pid=$( ps x | grep -v grep | grep "mongod" | awk '{ print $1 }' )
      `kill -2 ${pid}`
      RETVAL=$?
    else
      echo "MongoDB is not running."
    fi
  fi
}

check_for_mongod
RETVAL=$?

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: ${prog} {start|stop|restart}"
    ;;
esac

exit $RETVAL
