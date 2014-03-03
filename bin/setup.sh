#!/bin/bash --login

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

# Load the correct ruby version and gemset if one is specified.
if [ -f ".ruby-version" ]; then
  if [ -f ".ruby-gemset" ]; then
    rvm use `cat .ruby-version`@`cat .ruby-gemset`
  else
    rvm use `cat .ruby-version`
  fi
else
  # Project did not come with a .ruby-version
  echo "Project does not contain a .ruby-version file."
  echo "Please add a .ruby-version file to the project."
fi

# If there is a brewfile, run brew bundle to install dependencies
if [ -f "Brewfile" ]; then
  brew bundle
fi

# Set up the gem environment
bundle install

# Setup config files

example_files=$( find config -name *.yml.example )
for file in $example_files; do
  echo "$file"
done

# Setup the database.
# db:setup runs: rake db:create; db:migrate; db:seed
#rake db:setup
