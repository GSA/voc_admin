module DashboardsHelper

  # Links the JSON data from the ChoiceQuestionReporter model
  # to the JQuery plugin function call.
  def generate_element_data_script(element)
    type = element.display_type
    data = element.element_data

    if type == 'word_cloud'
      if data == "null"
        ""
      else
        "$('##{type}Element_#{element.id}').jQCloud(#{data});"
      end
    else
      chart_type = type == 'pie' ? 'Pie' : 'Column'
      if type == 'pie'
        %Q[
            var data_#{element.id} = new google.visualization.DataTable();
            data_#{element.id}.addColumn('string', 'Question');
            data_#{element.id}.addColumn('number', 'Count');
            data_#{element.id}.addRows(#{data});
            var chart_#{element.id} = new google.visualization.#{chart_type}Chart(document.getElementById('#{type}Element_#{element.id}'));
            chart_#{element.id}.draw(data_#{element.id}, #{type}Options);
          ]
      elsif type == 'bar'
        %Q[
            var data_arr_#{element.id} = #{data};
            var data_#{element.id} = google.visualization.arrayToDataTable(data_arr_#{element.id}, true);
            var columns = [0];
            for (var i = 0; i < data_#{element.id}.getNumberOfRows(); i++) {
                columns.push({
                    type: 'number',
                    label: data_#{element.id}.getValue(i, 0),
                    calc: (function (x) {
                        return function (dt, row) {
                            return (row == x) ? dt.getValue(row, 1) : null;
                        }
                    })(i)
                });
            }
            var view_#{element.id} = new google.visualization.DataView(data_#{element.id});
            view_#{element.id}.setColumns(columns);
            var chart_#{element.id} = new google.visualization.#{chart_type}Chart(document.getElementById('#{type}Element_#{element.id}'));
            chart_#{element.id}.draw(view_#{element.id}, #{type}Options);
          ]
      end
    end
  end

  # Spool through all elements and generate JS blocks for each
  def generate_dashboard_data_script(elements)
    elements.map do |element|
      generate_element_data_script(element)
    end.join("\n").html_safe
  end

  def render_dashboard_element (dashboard_element)
    type = dashboard_element.display_type

    %Q[<div class="dashboardElementDiv #{type}ElementDiv">
      <h4 class="dashboardElementHeader ellipse" title="#{dashboard_element.question}">#{dashboard_element.question}</h4>
      <div class="dashboardElementCount">Number of responses: #{number_with_delimiter(dashboard_element.answered)}</div>
      <div id="#{type}Element_#{dashboard_element.id}" class="dashboardElement #{type}Element"></div>
    </div>].html_safe
  end

  def dashboard_element_display_types_arr
    DashboardElement::DISPLAY_TYPES.map {|k,v| [v, k, {"data-type" => k}]}
  end

  def truncate_question(question, length = 40)
    truncate question, :length => length, :separator => ' ', :omission => "..."
  end
end
