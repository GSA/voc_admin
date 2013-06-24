
namespace :reporting do
  desc "Push all survey responses to NOSQL"
  task :export_all => [:environment] do

    criteria = SurveyResponse.all

    # in case of failure / cancel, pick up where you left off:
    # criteria = SurveyResponse.where("id > 64276")

    total = criteria.count
    page_size = 500
    batches = (total / page_size.to_f).ceil
    errors = 0

    puts "Starting export for #{total} records in #{batches} batches of #{page_size}..."

    (1..batches).each do |num|
      puts "  Starting batch #{num}..."

      criteria.page(num).per(page_size).each do |sr|
        puts "    (B #{num}/#{batches}: Exporting ID# #{sr.id}..."

        begin
          sr.export_for_reporting
        rescue
          puts "    ...failed with error: #{$!.to_s}"
          errors += 1
        end
      end

      puts "  ...batch #{num} finished."
    end

    puts "...export finished. #{errors} errors."
  end
end