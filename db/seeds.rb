# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

SurveyType.create! :id => 1, :name => "site"
SurveyType.create! :id => 2, :name => "page"

Conditional.create! :id=>1, :name=>"="
Conditional.create! :id=>2, :name=>"!="
Conditional.create! :id=>3, :name=>"contains"
Conditional.create! :id=>4, :name=>"does not contain"
Conditional.create! :id=>5, :name=>"<"
Conditional.create! :id=>6, :name=>"<="
Conditional.create! :id=>7, :name=>">="
Conditional.create! :id=>8, :name=>">"
Conditional.create! :id=>9, :name=>"empty"
Conditional.create! :id=>10, :name=>"not empty"

Status.create! :id=>1, :name=>"new"
Status.create! :id=>2, :name=>"processing"
Status.create! :id=>3, :name=>"error"
Status.create! :id=>4, :name=>"done"

ExecutionTrigger.create! :id=>1, :name=>"add"
ExecutionTrigger.create! :id=>2, :name=>"update"
ExecutionTrigger.create! :id=>3, :name=>"delete"
ExecutionTrigger.create! :id=>4, :name=>"nightly"