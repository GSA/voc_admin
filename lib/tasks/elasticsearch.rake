namespace :elasticsearch do
  desc "Remove the elasticsearch index specified"
  task :remove_index, [:index_name] => [:environment] do |t, args|
    puts "Deleting index: #{args[:index_name]}"
    ELASTIC_SEARCH_CLIENT.indices.delete index: args[:index_name]
  end

  desc "Create survey_responses index and mappings"
  task :create_index, [:index_name] => [:environment] do |t, args|
    puts "Creating index: #{args[:index_name]}"
    ELASTIC_SEARCH_CLIENT.indices.create index: args[:index_name],
      body: ELASTIC_SEARCH_MAPPINGS[args[:index_name].to_sym]
  end

  desc "Truncate survey_responses index"
  task :truncate_survey_responses_index => [:environment] do
    Rake::Task['elasticsearch:remove_index'].invoke ELASTIC_SEARCH_INDEX_NAME
    Rake::Task['elasticsearch:create_index'].invoke ELASTIC_SEARCH_INDEX_NAME
  end

  desc "Export to elastic search"
  task :export_to_elastic_search => [:environment] do
    per_batch = 1000
    total = ReportableSurveyResponse.count
    0.step(total, per_batch) do |offset|
      ReportableSurveyResponse.limit(per_batch).skip(offset).each do |response|
        begin
          response.elastic_search_persist
        rescue
          puts "Caught exception raised by ReportableSurveyResponse: #{response.id}"
        end
      end
      puts "Exported batch to elasticsearch: #{offset+per_batch}/#{total}"
    end
  end
end
