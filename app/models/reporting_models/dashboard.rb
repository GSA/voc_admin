class Dashboard < ActiveRecord::Base
  belongs_to :survey_version

  has_many :text_widgets,     :through => :widgets, :source => :reportable, :source_type => "TextWidget",    :dependent => :destroy
  has_many :choice_widgets,   :through => :widgets, :source => :reportable, :source_type => "ChoiceWidget",  :dependent => :destroy
  has_many :matrix_widgets,   :through => :widgets, :source => :reportable, :source_type => "MatrixWidget",  :dependent => :destroy
end
