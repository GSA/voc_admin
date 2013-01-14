class DisplayField < ActiveRecord::Base
  has_many :display_field_categories, :dependent => :destroy
  has_many :categories, :through=>:display_field_categories

  has_many :display_field_values, :dependent => :destroy

  has_many :display_field_custom_views, :dependent => :destroy
  has_many :custom_views, :through => :display_field_custom_views

  belongs_to :survey_version

  validates :name, :presence => true, :uniqueness => {:scope => :survey_version_id}
  validates :type, :presence => true
  validates :display_order, :presence => true, :uniqueness => { :scope => :survey_version_id }
  validates_inclusion_of :editable, :in => [true, false]

  has_many :criteria, :as=>:source

  validates :choices, :presence => { :if => Proc.new { |obj| obj.type != "DisplayFieldText" } }

  before_save :strip_default_value, :strip_choices

  before_validation :default_values

  def default_values
    self.editable = true if self.editable.nil?
    return true
  end

  def strip_default_value
    if self.type == "DisplayFieldChoiceMultiselect"
      self.default_value = nil
    end
  end

  def strip_choices
    if self.type == "DisplayFieldText"
      self.choices = nil
    end
  end

  def increment_display_order
    target_display_order = self.display_order + 1
    self.move_display_field(target_display_order) unless target_display_order > self.survey_version.display_fields.count
  end

  def decrement_display_order
    target_display_order = self.display_order - 1
    self.move_display_field(target_display_order) unless target_display_order <= 0
  end

  def move_display_field(target_display_order)
    DisplayField.transaction do
      start_index, end_index = target_display_order < self.display_order ? [target_display_order,self.display_order] : [self.display_order,target_display_order]

      #shift range from target to source (overright source with it's neighbor in direction of target)
      if target_display_order < self.display_order
        self.survey_version.display_fields.where(['display_order >= ? and display_order < ?', start_index, end_index]).update_all("display_order = display_order + 1")
      else
        self.survey_version.display_fields.where(['display_order > ? and display_order <= ?', start_index, end_index]).update_all("display_order = display_order - 1")
      end

      #update source to target
      self.update_attribute(:display_order, target_display_order)
    end
  end

  def model_type=(m_type)
    write_attribute(:type, m_type)
  end

  def model_type
    self.type
  end

  def self.select_options
    # TODO: reenable this when display field validations have been implemented
    # to allow a user to select a different display field type.
    #subclasses.map {|c| [c.to_s.titleize.split(' ')[2..-1].join(' '), c.to_s]}.sort
    [['Text','DisplayFieldText'], ['Dropdown', 'DisplayFieldChoiceSingle'], ['Checkboxes', 'DisplayFieldChoiceMultiselect']]
  end

  def check_condition(survey_response, conditional_id, test_value)

    #find the existing value displayfieldvalue
    display_field_value = DisplayFieldValue.find_or_create_by_survey_response_id_and_display_field_id(survey_response.id, self.id)
    return(false) unless display_field_value
    answer = display_field_value.value || ''

    case conditional_id
      when 1 #"="
        answer == test_value
      when 2 #"!="
        answer != test_value
      when 3 #"contains"
        answer.match /#{test_value}/i || false
      when 4 #"does not contain"
        !(answer.match /#{test_value}/i || false)
      when 5 #"<"
        answer.to_i < test_value.to_i
      when 6 #"<="
        answer.to_i <= test_value.to_i
      when 7 #">="
        answer.to_i >= test_value.to_i
      when 8 #">"
        answer.to_i > test_value.to_i
      when 9 #"empty"
        answer.blank?
      when 10 #"not empty"
        !answer.blank?
      else
        false
    end
  end

  def get_display_field_header
    self.name
  end

  def clone_me(target_sv)
    df = target_sv.display_fields.find_by_name(self.name)
    return df if df
    DisplayField.create!(self.attributes.merge(:clone_of_id=>self.id, :survey_version_id =>target_sv.id, :model_type=>self.type, :display_order => self.display_order))
  end

  def find_my_clone_for(target_sv)
    df = target_sv.display_fields.find_by_clone_of_id(self.id)
  end

  def populate_default_values!
    self.survey_version.survey_responses.find_in_batches do |survey_responses|
      survey_responses.each do |sr|
        self.display_field_values.create! :survey_response_id => sr.id, :value => self.default_value unless self.display_field_values.find_by_survey_response_id(sr.id)
      end
    end
  end
end


# == Schema Information
#
# Table name: display_fields
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)     not null
#  type              :string(255)     not null
#  required          :boolean(1)      default(FALSE)
#  searchable        :boolean(1)      default(FALSE)
#  default_value     :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  display_order     :integer(4)      not null
#  survey_version_id :integer(4)
#  clone_of_id       :integer(4)
#  choices           :string(255)
#  editable          :boolean(1)      default(TRUE)
#

