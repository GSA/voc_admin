class DashboardElement < ActiveRecord::Base
  include ActionView::Helpers::TextHelper 

  belongs_to :dashboard
  belongs_to :survey_element

  include RankedModel
  ranks :sort_order, :with_same => :dashboard_id

  default_scope order(:sort_order)

  # dashboard element types
  DISPLAY_TYPES = {
    :bar => "Bar Chart",
    :pie => "Pie Chart",
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

  def question
    @question ||= reporter.question
  end

  def element_data
    reporter.generate_element_data(display_type, dashboard.start_date, dashboard.end_date)
  end

  def answered
    reporter.answered_for_date_range(dashboard.start_date, dashboard.end_date)
  end
end
