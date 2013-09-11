module DashboardsHelper

  # Links the JSON data from the ChoiceQuestionReporter model
  # to the JQuery plugin function call.
  def generate_element_data_script(element)
    type = element.display_type

    %Q[
	        var data_#{element.id} = #{element.element_data};
	        $.plot("##{type}Element_#{element.id}", data_#{element.id}, #{type}Options);]
  end

  # Spool through all elements and generate JS blocks for each
  def generate_dashboard_data_script(elements)
    elements.map do |element|
      generate_element_data_script(element)
    end.join("\n").html_safe
  end

  def render_dashboard_element (dashboard_element)
      type = dashboard_element.display_type

      %Q[<div class="#{type}ElementDiv">
        <h4 class="dashboardElementHeader ellipse" title="#{dashboard_element.question}">#{dashboard_element.question}</h4>
        <div id="#{type}Element_#{dashboard_element.id}" class="dashboardElement #{type}Element"></div>
      </div>].html_safe
  end

  def dashboard_element_types_arr
    DashboardElement::ELEMENT_TYPES.map {|k,v| [v, k]}
  end

  def truncate_question(question, length = 40)
    truncate question, :length => length, :separator => ' ', :omission => "..."
  end
end
