namespace :elasticsearch do
  desc "Remove the elasticsearch index specified"
  task :remove_index, [:index_name] => [:environment] do |t, args|
    puts "Deleting index: #{args[:index_name]}"
    ELASTIC_SEARCH_CLIENT.indices.delete index: args[:index_name]
  end

  desc "Create survey_responses index and mappings"
  task :create_index, [:index_name] => [:environment] do
    puts "Creating index: #{args[:index_name]}"
    ELASTIC_SEARCH_CLIENT.indices.create index: args[:index_name],
      body: ELASTIC_SEARCH_MAPPINGS[args[:index_name].to_sym]
  end

  desc "Truncate survey_responses index"
  task :truncate_survey_responses_index => [:environment] do
    Rake::Task['elasticsearch:remove_index'].invoke('survey_responses')
    Rake::Task['elasticsearch:create_index'].invoke('survey_responses')
  end

  desc "Export to elastic search"
  task :export_to_elastic_search => [:environment] do
    per_batch = 1000
    total = ReportableSurveyResponse.where(survey_id: 12).count
    0.step(total, per_batch) do |offset|
      ReportableSurveyResponse.where(survey_id: 12).limit(per_batch).skip(offset).each(&:elastic_search_persist)
      puts "Exported batch to elasticsearch: #{offset+per_batch}/#{total}"
    end
  end
end
