#!/bin/sh

# Start all databases needed for the project
brew services start mysql
brew services start mongodb
brew services start redis
