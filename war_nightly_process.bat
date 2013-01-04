SET RAILS_ENV=production
SET BUNDLE_WITHOUT=development:test
SET BUNDLE_GEMFILE=Gemfile
SET GEM_HOME=gems
java -classpath "lib/*" org.jruby.Main -S rake nightly_rules:process RAILS_ENV=production
pause