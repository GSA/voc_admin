TIMEZONE_STR = "Eastern Time (US & Canada)"
start_date = ActiveSupport::TimeZone[TIMEZONE_STR].parse("2016-01-21")
end_date = ActiveSupport::TimeZone[TIMEZONE_STR].parse("2016-01-25")

last_processed_response = SurveyResponse
  .where("created_at >= ? and created_at <= ?", start_date, end_date)
  .order("created_at desc")
  .first

last_processed_at = last_processed_response.created_at

# puts last_processed_response.inspect
puts "Last processed response at: #{last_processed_at}"

processing_restarted_at = SurveyResponse
  .where("created_at >= ?", ActiveSupport::TimeZone[TIMEZONE_STR].parse("2016-01-24"))
  .where("created_at <= ?", ActiveSupport::TimeZone[TIMEZONE_STR].parse("2016-01-26"))
  .order("created_at asc")
  .first
  .created_at

puts "First processed response at: #{processing_restarted_at}"

unprocessed_raw_submissions = RawSubmission
  .where("created_at >= ? and created_at <= ?", last_processed_at + 1.second, processing_restarted_at-1.second)
  .where(submitted: true)
  .order("created_at desc")

survey_responses = SurveyResponse
  .where("created_at >= ? and created_at <= ?", last_processed_at + 1.second, processing_restarted_at-1.second)
  .order("created_at desc")

puts "Unprocessed RawSubmissions: #{unprocessed_raw_submissions.count}"
puts "SurveyResponses Count: #{survey_responses.count}"

unprocessed_raw_submissions.each do |raw_submission|
  resque_args = raw_submission.post["response"], raw_submission.post["survey_version_id"], raw_submission.updated_at
  puts "Re-Queue raw_submission: #{resque_args.inspect}"
  Resque.enqueue(SurveyResponseCreateJob, *resque_args)
end
