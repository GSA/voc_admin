#!/bin/sh

# Start/Stop redis server

# Stop the script if there is an error in a subprocess
set -e

redis=$(command -v redis-server)
script_dir=$( cd $(dirname $0) ; pwd -P )
config_dir="${script_dir}/../config"
config_file="${config_dir}/redis.conf"
pid_file="${script_dir}/../tmp/pids/redis.pid"
logfile="${script_dir}/../log/redis.log"

RETVAL=0

check_for_redis_server() {
  if ! command -v redis-server > /dev/null 2>&1;then
    echo "Redis is not installed!"
    echo "Redis must be installed to run VOC."
    exit 1
  fi
}

start() {
  if [[ -e ${config_file} ]]; then
    # Use the config file to start the redis server
    echo "Config file (config/redis.conf) found."
    echo "Starting redis using config file."
    `${redis} ${config_file}`
    RETVAL=$?
  else
    # No config file. Use project defaults
    echo "No config file found."
    echo "Starting redis using project defaults on the command line."
    `${redis} --daemonize yes --pidfile ${pid_file} --logfile ${logfile}`
    RETVAL=$?
  fi
}

stop() {
  if [[ -e ${pid_file} ]]; then
    # Use the PID file to get the running PID
    pid=`cat ${pid_file}`
    echo "PID file found.  Stopping Redis instance (${pid})."
    `kill -2 ${pid}`
    RETVAL=$?

    if [ $RETVAL -eq 0 ]; then
      `rm ${pid_file}`
    fi
  else
    # No PID file found.  See if a process is running with grep
    redis_grep=`ps aux | grep -v grep | grep "redis-server"`
    if [ ${#redis_grep} -gt 0 ]; then
      pid=`ps x | grep -v grep | grep "redis-server" | awk '{ print $1 }'`
      `kill -2 ${pid}`
      RETVAL=$?
    else
      echo "No Redis instance running."
    fi
  fi
}

check_for_redis_server

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
