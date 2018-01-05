#!/bin/bash --login

rake db:mongoid:drop db:mongoid:create_indexes
rake elasticsearch:remove_index['survey_responses_development'] elasticsearch:create_index['survey_responses_development']
rake reporting:reload_questions
rake reporting:export_all
rake reporting:update_survey_version_counts

echo '=== Data Load Complete ==='
say 'Data Load Complete'
