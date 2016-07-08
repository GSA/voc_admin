# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Upon stated criteria being fulfilled, Rules are used to send notification emails to recipients or update
# question DisplayFieldValues or custom DisplayFields.  Rule Actions may insert/update values or copy
# them between question DisplayFieldValues and custom DisplayFields as requested.
class Rule < ActiveRecord::Base
  include ResqueAsyncRunner
  @queue = :voc_rules

  has_many :actions, :dependent => :destroy
  has_one  :email_action, :dependent => :destroy
  has_many :criteria, :dependent => :destroy
  has_many :execution_trigger_rules, :dependent => :destroy
  has_many :execution_triggers, :through => :execution_trigger_rules

  belongs_to :survey_version

  after_destroy :reorder_rules

  validates :name, :presence => true
  validates :rule_order, :presence => true, :uniqueness => {:scope => :survey_version_id}
  validates_numericality_of :rule_order, :only_integer => true
  validates :survey_version, :presence => true
  validates :execution_triggers, :presence => true
  validates :action_type, :presence => true
  validates :actions, :presence => true, :if => Proc.new { |rule| rule.action_type == 'db' }
  validates :email_action, :presence => true, :if => Proc.new {|rule| rule.action_type == 'email' }

  accepts_nested_attributes_for :criteria, :reject_if => lambda {|attrs| !["9", "10"].include?(attrs[:conditional_id].to_s) && attrs[:value].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :actions, :reject_if => lambda {|attrs| attrs[:value].blank? || attrs[:action_type] == 'email'}, :allow_destroy => true
  accepts_nested_attributes_for :email_action, :reject_if => lambda {|attrs| attrs[:action_type] == 'db' || attrs['body'].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :execution_trigger_rules, :reject_if => lambda {|attrs| attrs[:execution_trigger_id].blank?}, :allow_destroy => true

  # Moves a selected Rule down in the list, reordering the list.
  def increment_rule_order
    target_rule_order = self.rule_order + 1
    self.move_rule(target_rule_order) unless target_rule_order > self.survey_version.display_fields.count
  end

  # Moves a selected Rule up in the list, reordering the list.
  def decrement_rule_order
    target_rule_order = self.rule_order - 1
    self.move_rule(target_rule_order) unless target_rule_order <= 0
  end

  # Reorders the Rule list in a DB transaction when a Rule is moved.
  #
  # @param [Integer] target_rule_order the index of the Rule order to move the Rules around.
  def move_rule(target_rule_order)
    Rule.transaction do
      start_index, end_index = target_rule_order < self.rule_order ? [target_rule_order,self.rule_order] : [self.rule_order,target_rule_order]

      #shift range from target to source (overright source with it's neighbor in direction of target)
      if target_rule_order < self.rule_order
        self.survey_version.rules.where(['rule_order >= ? and rule_order < ?', start_index, end_index]).update_all("rule_order = rule_order + 1")
      else
        self.survey_version.rules.where(['rule_order > ? and rule_order <= ?', start_index, end_index]).update_all("rule_order = rule_order - 1")
      end

      #update source to target
      self.update_attribute(:rule_order, target_rule_order)
    end
  end

  # Tests criteria and performs Actions / EmailActions upon success.
  #
  # @param [SurveyResponse] survey_response the SurveyResponse to evaluate
  def apply_me(survey_response)
    # checks all criteria one at a time; ANDs the result with true to determine match
    if(self.criteria.inject(true) {|result, c| result && c.check_me(survey_response)})
      self.actions.each { |a| a.perform(survey_response)} unless self.actions.empty?
      self.email_action.perform(survey_response) if self.email_action
    end
  end

  # Applies this Rule to all SurveyResponses in turn.
  def apply_me_all
    SurveyResponse.where(survey_version_id: self.survey_version_id).each do |sr|
      self.apply_me(sr)
    end
  end

  # Deep clones the Rule, Criteria, Actions, and EmailActions during a SurveyVersion
  # clone operation.
  #
  # @param [SurveyVersion] target_sv the SurveyVersion to which the clone should be associated
  # @return [Rule] the freshly created Rule
  def clone_me(target_sv)
    return if target_sv.rules.find_by_name(self.name)

    r_attribs = self.attributes
    r_attribs.delete("id")
    r_attribs["action_type"] ||= 'db'

    a_attribs = self.actions.map do |action|
      attribs = action.attributes.merge(:clone_of_id =>  action.id)
      attribs.delete("id")

      #fix the display_field_id
      new_display_field = DisplayField.find_by_survey_version_id_and_clone_of_id(target_sv.id, action.display_field_id)
      next unless new_display_field # If we can't find the newly cloned display field then this is now an invalid action so don't clone the rule

      if action.value_type == "Response"
        response_qc = self.survey_version.options_for_action_select.select {|x| x[1] == action.value }.first
        next if response_qc.nil?

        new_value = target_sv.options_for_action_select.select {|x| x[0] == response_qc[0]}.try(:first).try(:last)
        attribs.merge!(:value => new_value) if new_value
      end

      attribs = attribs.merge(
        :display_field_id => (new_display_field.id)
      )

      attribs
    end
    a_attribs.compact!

    ea_attribs = email_action.try(:attributes)
    ea_attribs.merge(:clone_of_id => email_action.id) if ea_attribs.present?
    ea_attribs.delete("id") if ea_attribs.present?

    c_attribs = self.criteria.map do |criterion|
      attribs = criterion.attributes.merge(:clone_of_id => criterion.id)
      attribs.delete("id")

      #fix the source_id
      new_source = criterion.source.try(:find_my_clone_for, target_sv)
      return unless new_source # if we can't find the new source clone then this is now an invalid criterion so don't clone the rule

      attribs = attribs.merge(
        :source_id => (new_source.id)
      )
    end

    r_attribs = r_attribs.merge(
      :execution_triggers => self.execution_triggers,
      :actions_attributes => a_attribs,
      :email_action_attributes =>  ea_attribs || {},
      :criteria_attributes => c_attribs,
      :survey_version_id => (target_sv.id),
      :clone_of_id => (self.id),
      :rule_order => target_sv.rules.count + 1
    )
    clone_rule = Rule.new(r_attribs)
    clone_rule.save!
    clone_rule
  end

  private

  # Decrement all later rules when this rule is destroyed.
  def reorder_rules
    self.survey_version.rules.where(['rules.rule_order > ?', self.rule_order])
      .update_all('rules.rule_order = rules.rule_order - 1')
  end
end

# == Schema Information
#
# Table name: rules
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  created_at        :datetime
#  updated_at        :datetime
#  survey_version_id :integer          not null
#  rule_order        :integer          not null
#  clone_of_id       :integer
#  action_type       :string(255)      default("db")
#

