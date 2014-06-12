#!/bin/sh

# Stop all databases required for project
brew services stop redis
brew services stop mongodb
brew services stop mysql
