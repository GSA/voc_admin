#!/bin/sh

# Start all databases needed for the project

bin_path=$( cd $(dirname $0) ; pwd -P )
mysql_status=$( mysql.server status | grep "ERROR" )

RETVAL=0

# Start MySQL if it is not running
if [ ${#mysql_status} -gt 0 ]; then
  echo "MySQL is not running."
  echo "Starting MySQL."
  `mysql.server start > /dev/null`
  RETVAL=$?
else
  echo "MySQL is already running."
fi

# Start mongod
echo $( ${bin_path}/mongod.sh start )
RETVAL=$?
if [ $RETVAL -gt 0 ]; then
  # Failed to start mongod
  echo "Failed to start MongoDB."
  exit 1
else
  echo "Successfully started MongoDB."
fi

# Start redis
echo $( ${bin_path}/redis.sh start )
RETVAL=$?
if [ $RETVAL -gt 0 ]; then
  echo "Failed to start redis."
  exit 1
else
  echo "Successfully started Redis."
fi

echo "Congratulations! You are now ready to start running Comment Tool."
echo "Use 'rails s -p <port>' to run the rails server."
