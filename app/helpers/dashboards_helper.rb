module DashboardsHelper

  # Links the JSON data from the ChoiceQuestionReporter model
  # to the JQuery plugin function call.
  def generatePieChart(chart)
    %Q[
	        var data_#{chart.id} = #{chart.pie_chart_data};
	        $.plot("#pieChart_#{chart.id}", data_#{chart.id}, pieOptions);]
  end

  # Spool through all charts and generate JS blocks for each
  def generatePieChartsJS(charts)
    charts.map { |chart| generatePieChart(chart) }.join("\n").html_safe
  end

  def dashboard_element_types_arr
    DashboardElement::ELEMENT_TYPES.map {|k,v| [v, k]}
  end

  def truncate_question(question, length = 40)
    truncate question, :length => length, :separator => ' ', :omission => "..."
  end
end