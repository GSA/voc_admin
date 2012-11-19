module SurveyResponsesHelper
  def display_question_answer(response)
    return "<i>No Answer</i>".html_safe if response.nil?
    case response.question_content.questionable_type
    when "ChoiceQuestion"
      ChoiceAnswer.find(response.answer.to_i).answer
    when "TextQuestion"
      response.answer
    else
      ""
    end
  end

  def sortable_display_field column, title = nil
    direction = (column == params[:order_column] && params[:order_dir] == "asc") ? "desc" : "asc"

    title ||= column.titleize

    arrows = content_tag :span, :class => "sort_arrows" do
      ret = ""
      if column == params[:order_column]
        ret += image_tag "arrow_up_larger.png", :alt => "Sort"   if direction == "desc"
        ret += image_tag "arrow_down_larger.png", :alt => "Sort" if direction == "asc"
      else
        ret += image_tag "arrows.png", :alt => "Sort"
      end
      ret.html_safe
    end

    title += arrows

    link_to_function title.html_safe, "sortByDisplayField('#{CGI.escape(column)}', '#{direction}')"
  end

  def get_edit_current_view_link version, current_view
    edit_link = "Edit Current View"

    edit_link = link_to edit_link, edit_survey_survey_version_custom_view_path(version.survey, version, current_view), {:class => "manage"} unless current_view.nil?

    edit_link
  end

  def options_for_include_exclude(default = nil)
    options_for_select([ ['Include', 1], ['Exclude', 0]],
     :selected => default
    )
  end

  def options_for_conditions(default = nil)
    options_for_select( [['Exactly Matches', 'equals'], ['Containing', 'contains'], ['Begins With', 'begins_with'], ['Ends With', 'ends_with'], ['Less Than', 'less_than'], ['Greater Than', 'greater_than']],
      :selected => default)
  end
end
