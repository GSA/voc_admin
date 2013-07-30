module DashboardsHelper
	
	# Links the JSON data from the ChoiceQuestionReporter model
	# to the JQuery plugin function call.
	def generatePieChart(chart)
%Q[
	var data_#{chart.id} = #{chart.pie_chart_data};

	$.plot("#pieChart_#{chart.id}", data_#{chart.id}, {
			series: {
				pie: {
					show: true
				}
			},
			grid: {
				hoverable: true
			},
			legend: {
				show: true,
				labelFormatter: function(label, series) {
					return label + ' (' + series.data[0][1] + ')';
				}
			}
		});
]
	end

	# Spool through all charts and generate JS blocks for each
	def generatePieChartsJS(charts) 
		charts.map { |chart| generatePieChart(chart) }.join("\n").html_safe
	end
end