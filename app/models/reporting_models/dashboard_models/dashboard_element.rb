class DashboardElement < ActiveRecord::Base
  include ActionView::Helpers::TextHelper 

  belongs_to :dashboard
  belongs_to :survey_element

  serialize :options

  include RankedModel
  ranks :sort_order, :with_same => :dashboard_id

  # Generate the data required to plot a pie chart.
  #
  # @return [String] JSON data
  def pie_chart_data
    choice_answer_reporters = survey_element.reporter.choice_answer_reporters

    # build an array of data to convert to JSON
    [].tap do |data|
      case options.try(:[], :type)
      when 'count_per_answer_option'
        data.push(*count_per_answer_option_data(choice_answer_reporters))
      else
        nil
      end
    end.to_json
  end

  private

  # Generate data for the "Count per answer option" chart display. Creates an array
  # of Hash objects, which are required for Flot charting.
  #
  # @param [Array<ChoiceAnswerReporter>] Reporting objects for each answer option
  #
  # @return [Array<Hash>] Hash of data for each answer option
  def count_per_answer_option_data(choice_answer_reporters)
    choice_answer_reporters.map do |choice_answer_reporter|
      { label: shorten(choice_answer_reporter.text), data: choice_answer_reporter.count }
    end
  end

  def shorten(text, length = 20)
    truncate text, :length => length, :separator => ' ', :omission => "&hellip;"
  end
end
