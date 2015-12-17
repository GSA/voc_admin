# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A DisplayField (at the base level) represents a column of question response or admin-defined data.
#
# The intersection of a SurveyResponse and a DisplayField is a DisplayFieldValue, which represents how a
# single respondent answered a specific ChoiceQuestion or TextQuestion (as MatrixQuestions are comprised of
# multiple ChoiceQuestions.)
#
# DisplayFields also represent admin-defined data.  These are columns which are not populated by a
# survey respondent, instead filled in through Actions triggered by Rules.
#
# DisplayFields based on questions have readonly DisplayFieldValues; admin-defined DisplayFields' values
# are editable.
#
# DisplayFields are also tracked by CustomViews to determine column ordering.
class DisplayField < ActiveRecord::Base
  include ResqueAsyncRunner
  def self.queue; :voc_dfs; end  # this has to be a class method because DisplayField is a parent

  require 'condition_tester'

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

  # Ensures, upon validation, that a DisplayField is set to be editable
  # unless it has been explicitly created not to be (i.e. DB-backed.)
  def default_values
    self.editable = true if self.editable.nil?
    return true
  end

  # Removes the default value from a DisplayFieldChoiceMultiselect (N/A) upon save.
  def strip_default_value
    if self.type == "DisplayFieldChoiceMultiselect"
      self.default_value = nil
    end
  end

  # Removes choices from DisplayFieldText (N/A) upon save.
  def strip_choices
    if self.type == "DisplayFieldText"
      self.choices = nil
    end
  end

  # Used to reorder a DisplayField right within the SurveyResponse standard view.
  def increment_display_order
    target_display_order = self.display_order + 1
    self.move_display_field(target_display_order) unless target_display_order > self.survey_version.display_fields.count
  end

  # Used to reorder a DisplayField left within the SurveyResponse standard view.
  def decrement_display_order
    target_display_order = self.display_order - 1
    self.move_display_field(target_display_order) unless target_display_order <= 0
  end

  # Invoked when increment_display_order or decrement_display_order are used; reorders other DisplayFields appropriately.
  #
  # @param [Integer] target_display_order defines the threshold index used to reorder DisplayFields
  def move_display_field(target_display_order)
    DisplayField.transaction do
      start_index, end_index = target_display_order < self.display_order ?
        [target_display_order,self.display_order] :
        [self.display_order,target_display_order]

      #shift range from target to source (overright source with it's neighbor in direction of target)
      if target_display_order < self.display_order
        self.survey_version.display_fields
          .where(['display_order >= ? and display_order < ?', start_index, end_index])
          .update_all("display_order = display_order + 1")
      else
        self.survey_version.display_fields
          .where(['display_order > ? and display_order <= ?', start_index, end_index])
          .update_all("display_order = display_order - 1")
      end

      #update source to target
      self.update_attribute(:display_order, target_display_order)
    end
  end

  # Setter for the Questionable type.
  #
  # @param [String] m_type the type to set
  def model_type=(m_type)
    write_attribute(:type, m_type)
  end

  # Getter for the Questionable type.
  #
  # @return [String] the model type
  def model_type
    self.type
  end

  # Populates the Type dropdown on the DisplayField form view.
  def self.select_options
    # TODO: reenable this when display field validations have been implemented
    # to allow a user to select a different display field type.
    #subclasses.map {|c| [c.to_s.titleize.split(' ')[2..-1].join(' '), c.to_s]}.sort
    [
      ['Text','DisplayFieldText'],
      ['Dropdown', 'DisplayFieldChoiceSingle'],
      ['Checkboxes', 'DisplayFieldChoiceMultiselect']
    ]
  end

  # Used by Criteria in Rules to process survey_responses against Conditionals
  #
  # @param [SurveyResponse] survey_response a SurveyResponse to test
  # @param [Integer] conditional_id the operator used to test
  # @param [Object] test_value the value to test
  def check_condition(survey_response, conditional_id, test_value)

    #find the existing value displayfieldvalue
    display_field_value = DisplayFieldValue.find_or_create_by(survey_response_id: survey_response.id, display_field_id: self.id)
    return(false) unless display_field_value
    answer = display_field_value.value || ''

    ConditionTester.test(conditional_id, answer, test_value)
  end

  # Used to retrieve the name property on the Rule show view.
  def get_display_field_header
    self.name
  end

  # Duplicates the DisplayField upon cloning a SurveyVersion.
  #
  # @param [SurveyVersion] target_sv the SurveyVersion destination for the new cloned copy
  # @return [DisplayField] the cloned DisplayField
  def clone_me(target_sv)
    df = target_sv.display_fields.find_by_name(self.name)
    return df if df
    cloneable_attributes = self.attributes
      .except("id", "type", "created_at", "updated_at")
    DisplayField.create!(cloneable_attributes.merge(
        :clone_of_id=>self.id,
        :survey_version_id =>target_sv.id,
        :model_type=>self.type,
        :display_order => self.display_order
      )
    )
  end

  # Retrieve the clone for this DisplayField within a cloned SurveyVersion.
  #
  # @param [SurveyVersion] target_sv the SurveyVersion to search for the cloned copy.
  # @return [DisplayField] the original DisplayField
  def find_my_clone_for(target_sv)
    target_sv.display_fields.find_by_clone_of_id(self.id)
  end

  # Creates default DisplayFieldValue mappings on the current SurveyVersion's SurveyResponses.
  def populate_default_values!
    self.survey_version.survey_responses.find_in_batches do |survey_responses|
      survey_responses.each do |sr|
        unless self.display_field_values.find_by_survey_response_id(sr.id)
          self.display_field_values.create! :survey_response_id => sr.id,
            :value => self.default_value
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: display_fields
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  type              :string(255)      not null
#  required          :boolean          default(FALSE)
#  searchable        :boolean          default(FALSE)
#  default_value     :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  display_order     :integer          not null
#  survey_version_id :integer
#  clone_of_id       :integer
#  choices           :string(255)
#  editable          :boolean          default(TRUE)
#

