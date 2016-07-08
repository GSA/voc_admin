class DashboardElement < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  belongs_to :dashboard
  belongs_to :survey_element

  before_save :ensure_proper_display_type

  include RankedModel
  ranks :sort_order, :with_same => :dashboard_id

  default_scope { order(:sort_order) }

  # dashboard element types
  DISPLAY_TYPES = {
    :bar => "Bar Chart",
    :pie => "Pie Chart",
    :line => "Line Chart",
    :word_cloud => "Word Cloud"
  }.freeze

  def sort_order_position=(new_position)
    @sort_order_position = new_position
    sort_order_will_change!
  end

  def humanized_display_type
    DISPLAY_TYPES[display_type.try(:to_sym)]
  end

  def reporter
    @reporter ||= survey_element.reporter
  end

  def question_text
    @question ||= reporter.question_text
  end

  def element_data
    reporter.generate_element_data(display_type, dashboard.start_date, dashboard.end_date)
  end

  def answered
    reporter.answered_for_date_range(dashboard.start_date, dashboard.end_date)
  end

  protected

  # Enforce proper display type in case the UI allows the user to select an incorrect one
  def ensure_proper_display_type
    case reporter.try(:type)
    when :"choice-multiple"
      self.display_type = "bar" unless %w(bar line).include?(display_type)
    when :"choice-single"
      self.display_type = "bar" unless %w(bar pie line).include?(display_type)
    when :text
      self.display_type = "word_cloud"
    end
  end
end

# == Schema Information
#
# Table name: dashboard_elements
#
#  id                :integer          not null, primary key
#  dashboard_id      :integer
#  created_at        :datetime
#  updated_at        :datetime
#  survey_element_id :integer
#  sort_order        :integer
#  display_type      :string(255)
#

