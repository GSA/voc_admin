module DashboardsHelper

  # Links the JSON data from the ChoiceQuestionReporter model
  # to the JQuery plugin function call.
  def generate_element_data_script(element)
    type = element.display_type
    data = element.element_data

    case type
    when 'word_cloud'
      if data == "null"
        ""
      else
        "$('##{type}Element_#{element.id}').jQCloud(#{data});"
      end

    when 'pie'
      # create data_links, format number to have a delimiter, format legend, format tooltip
      # create chart, capture select to go to link
      %Q[
          var data_links_#{element.id} = #{Hash[element.reporter.choice_answer_reporters.map {|car| [car.text, car.ca_id]}].to_json};
          var data_#{element.id} = google.visualization.arrayToDataTable(#{data}, true);
          var formatter = new google.visualization.NumberFormat({pattern: '###,###'});
          formatter.format(data_#{element.id}, 1);
          formatter = new google.visualization.PatternFormat('{0}: {1} ({2})');
          formatter.format(data_#{element.id}, [0, 1, 2]);
          formatter = new google.visualization.PatternFormat('');
          formatter.format(data_#{element.id}, [], 1);
          var chart_#{element.id} = new google.visualization.PieChart(document.getElementById('#{type}Element_#{element.id}'));
          chart_#{element.id}.draw(data_#{element.id}, pieOptions);
          google.visualization.events.addListener(chart_#{element.id}, 'select', select#{element.id}Handler);
          function select#{element.id}Handler(e) {
            answer_text = data_#{element.id}.getValue(chart_#{element.id}.getSelection()[0].row, 0)
            search_text = data_links_#{element.id}[answer_text]
            window.location.href = "#{survey_responses_path(survey_id: @survey.id, survey_version_id: @survey_version.id, qc_id: element.reporter.qc_id)}&search_rr=" + search_text
          }
      ]
    else
      %Q[
          var data_#{element.id} = #{element.element_data};
          $.plot("##{type}Element_#{element.id}", data_#{element.id}, #{type}Options);
          $("##{type}Element_#{element.id}").bind("plotclick", function(event, pos, item) {
            if (item) {
              window.location.href = item.series.url;
            }
          });
      ]
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
      <h4 class="dashboardElementHeader ellipse" title="#{dashboard_element.question_text}">#{dashboard_element.question_text}</h4>
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
