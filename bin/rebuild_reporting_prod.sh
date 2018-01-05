#!/bin/bash --login
export RAILS_ENV=production

rake db:mongoid:drop db:mongoid:create_indexes
rake elasticsearch:remove_index['survey_responses_production'] elasticsearch:create_index['survey_responses_production']
rake reporting:reload_questions
rake reporting:export_all
rake reporting:update_survey_version_counts

echo '=== Data Load Complete ==='
