## Used to dump the old counts from the terramark redis instance
# redis_keys = SurveyVersion.redis.keys.select {|k| /survey_version:\d+:temp_visit_count/ =~ k}

# counts_hash = Hash.new
# redis_keys.each do |redis_key|
#   _, date_string, _ = redis_key.split(':')
#   counts_hash[date_string] = SurveyVersion.redis.hgetall redis_key
# end

# puts counts_hash.to_json


## Load the terramark redis counts into aws
require 'json'

file = File.read("#{Rails.root}/script/tm-redis-counts-hhs-voc.json")
json_data = JSON.parse(file)

json_data.each_pair do |sv_id, count_data|
  survey_version = SurveyVersion.where(id: sv_id).first
  next if survey_version.nil?
  puts "Incrementing counts for #{survey_version.id}"
  count_data.each_pair do |date_string, count|
    puts "\tIncrementing #{date_string} by #{count}"
    survey_version.temp_visit_count.incr(date_string, count)
  end
end
