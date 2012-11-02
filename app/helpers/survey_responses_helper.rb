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
        ret += image_tag "arrow_up.png"   if direction == "desc"
        ret += image_tag "arrow_down.png" if direction == "asc"
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

    edit_link = link_to edit_link, edit_survey_survey_version_custom_view_path(version.survey, version, current_view), {:class => "pageNav"} unless current_view.nil?

    edit_link
  end
end
