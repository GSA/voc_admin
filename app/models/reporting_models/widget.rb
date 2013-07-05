class Widget < ActiveRecord::Base
  belongs_to :reportable, polymorphic: true, :dependent => :destroy
  belongs_to :survey_version
end
