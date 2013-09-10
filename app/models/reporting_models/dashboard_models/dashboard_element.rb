class DashboardElement < ActiveRecord::Base
  include ActionView::Helpers::TextHelper 

  belongs_to :dashboard
  belongs_to :survey_element

  include RankedModel
  ranks :sort_order, :with_same => :dashboard_id

  default_scope order(:sort_order)

  ELEMENT_TYPES = {
    :count_per_answer_option => "Count Per Answer"
  }.freeze

  def sort_order_position=(new_position)
    @sort_order_position = new_position
    sort_order_will_change!
  end

  def humanized_element_type
    ELEMENT_TYPES[element_type.try(:to_sym)]
  end

  def reporter
    @reporter ||= survey_element.reporter
  end

  def question
    @question ||= reporter.question
  end

  def element_data
    reporter.generate_element_data(display_type, element_type)
  end

  def display_type
    reporter.allows_multiple_selection ? "bar" : "pie"
  end
end
