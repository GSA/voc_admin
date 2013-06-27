
namespace :reporting do
  # NOTE: you should run a few of these and then add an index to Mongo for
  # survey id, survey version id, and response ids
  desc "Push all once-plus-processed survey responses to NOSQL"
  task :export_all => [:environment] do

    criteria = SurveyResponse.processed

    # in case of failure / cancel, pick up where you left off:
    # criteria = criteria.where(survey_version_id: 76)

    total = criteria.count
    page_size = 500
    batches = (total / page_size.to_f).ceil
    errors = 0

    puts "Starting export for #{total} records in #{batches} batches of #{page_size}..."

    (1..batches).each do |num|
      num_in_batch = 1

      puts "  Starting batch #{num}..."

      criteria.page(num).per(page_size).each do |sr|
        print "\r    #{num}/#{batches} => #{num_in_batch}/#{page_size} Exporting SRID #{sr.id}..."

        begin
          sr.export_for_reporting
        rescue Exception => e
          print "\n    ...failed with error: #{$!.to_s}\n Backtrace: #{e.backtrace}"
          errors += 1
        end

        num_in_batch += 1
      end

      print "\n  ...batch #{num} finished.\n"
    end

    puts "...export finished. #{errors} errors."
  end
end