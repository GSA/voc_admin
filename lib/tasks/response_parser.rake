# Deprecated. This is no longer properly named for what it does.
# Rather than potentially breaking active installations,
# We'll just wrap and deprecate them instead.
namespace :response_parser do

  desc "Start response parsers (deprecated, use nightly_rules:start)"
  task :start => ["nightly_rules:start"]

  desc "Stop Response Parsers (deprecated, use nightly_rules:stop)"
  task :stop => ["nightly_rules:stop"]

end