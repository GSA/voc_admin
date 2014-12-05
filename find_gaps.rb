dates_with_responses = SurveyResponse.group("DATE(created_at)").count.keys
cal = (Date.parse("01/06/2014")..dates_with_responses.last)
dates_without_responses = cal.reject do |d|
  dates_with_responses.include?(d)
end

puts dates_without_responses

ranges = []
start_date = dates_without_responses.shift
end_date = start_date
for i in (0..dates_without_responses.count)
  next_date = dates_without_responses[i]
  if next_date == (end_date + 1.day)
    # We have a sequence
    end_date = next_date
  else
    # Not a sequence
    ranges.push(start_date..end_date)
    start_date = next_date
    end_date = next_date
  end
end

puts ranges

ranges.map! do |date_range|
  [(date_range.to_a.first..date_range.to_a.last + 1.day), SurveyResponse.where("created_at >= ? AND created_at < ?",(date_range.to_a.last + 1.day).beginning_of_day, (date_range.last + 1.day).end_of_day)]
end

ranges.each do |date_range, responses|
  num_buckets = date_range.to_a.size
  groups = responses.shuffle.in_groups(num_buckets)

  groups.each_with_index do |r, i|
    r.compact!
    d = date_range.to_a[i]
    r.each {|response|
      response.created_at = response.created_at.change(month: d.month, day: d.day, year: d.year)
      response.save!
    }
  end
end
