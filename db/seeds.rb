# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

print "creating default survey types..."
SurveyType.find_or_create_by_name("site") do |st|
  st.id = 1
end

SurveyType.find_or_create_by_name("page") do |st|
  st.id = 2
end

SurveyType.find_or_create_by_name("poll") do |st|
  st.id = 3
end

puts "done"

print "creating default conditionals..."
conditionals = [
  "=",
  "!=",
  "contains",
  "does not contain",
  "<",
  "<=",
  ">=",
  ">",
  "empty",
  "not empty"
]

conditionals.each_with_index do |c, index|
  Conditional.find_or_create_by_name(c) do |cond|
    cond.id = index + 1
  end
end
puts "done"


print "creating default survey statuses..."
%w(new processing error done).each_with_index do |status, index|
  Status.find_or_create_by_name(status) do |st|
    st.id = index + 1
  end
end
puts "done"


print "creating default execution triggers..."
%w(add update delete nightly).each_with_index do |trigger, index|
  ExecutionTrigger.find_or_create_by_name(trigger) do |et|
    et.id = index + 1
  end
end
puts "done"

print "creating default roles..."
Role.find_or_create_by_name("Admin")
puts "done"

print "Creating user: sysadmin@YOURCOMPANYURL.com..."
User.find_or_create_by_email("sysadmin@YOURCOMPANYURL.com") do |user|
  user.f_name = "System"
  user.l_name = "Administrator"
  user.username = "admin"
  #user.password = "password"
  #user.password_confirmation = "password"
  user.role_id = Role.find_by_name("Admin").id
end
puts "done"
