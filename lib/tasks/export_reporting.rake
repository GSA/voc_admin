
namespace :reporting do
  desc "Push all survey responses to NOSQL"
  task :export_all => [:environment] do

    # criteria = SurveyResponse

    # in case of failure / cancel, pick up where you left off:
    criteria = SurveyResponse.where("id > 64276")

    total = criteria.count
    page_size = 500
    batches = (total / page_size.to_f).ceil
    errors = 0

    puts "Starting export for #{total} records in #{batches} batches of #{page_size}..."

    (1..batches).each do |num|
      num_in_batch = 0

      puts "  Starting batch #{num}..."

      criteria.page(num).per(page_size).each do |sr|
        print "\r    #{num}/#{batches} => Exporting SRID #{sr.id}..."

        begin
          sr.export_for_reporting
        rescue
          print "\n    ...failed with error: #{$!.to_s}\n"
          errors += 1
        end
      end

      print "\n  ...batch #{num} finished.\n"
    end

    puts "...export finished. #{errors} errors."
  end
end