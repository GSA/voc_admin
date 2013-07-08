class Widget < ActiveRecord::Base
  belongs_to :dashboard
  belongs_to :report
end
