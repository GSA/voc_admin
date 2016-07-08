# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# View helpers for SurveyResponse functionality.
module SurveyResponsesHelper

  # Adds sort arrow images to table DisplayField columns.
  #
  # @param [String] column the name of the column being sorted
  # @param [String] title optional alternate display text for the column
  # @return [String] HTML link for the column header text, with sort toggle information
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

    link_to title.html_safe, "javascript:void(0);",
      onclick: "sortByDisplayField('#{CGI.escape(column)}', '#{direction}')"
  end

  # Retrieve the edit link for the current CustomView (or static text if no CustomView.)
  #
  # @param [SurveyVersion] version the current survey version
  # @param [CustomView, nil] current_view the current custom view, if applicable
  # @return [String] HTML link for the edit link
  def get_edit_current_view_link version, current_view
    edit_link = "Edit Current View"

    edit_link = link_to edit_link, edit_survey_survey_version_custom_view_path(version.survey, version, current_view), {:class => "manage"} unless current_view.nil?

    edit_link
  end

  # Retrieve the delete link for the current CustomView (or static text if no CustomView.)
  #
  # @param [SurveyVersion] version the current survey version
  # @param [CustomView, nil] current_view the current custom view, if applicable
  # @return [String] HTML link for the delete link
  def get_delete_current_view_link version, current_view
    delete_link = "Delete Current View"
    delete_link = link_to delete_link, survey_survey_version_custom_view_path(
      version.survey, version, current_view), {:class => "manage",
      :method => "delete"} unless current_view.nil?
    delete_link
  end

  # Generates HTML option tags for an Include/Exclude dropdown.
  #
  # @param [Integer] default the default selection, if applicable
  # @return [String] HTML option tags
  def options_for_include_exclude(default = nil)
    options_for_select([ ['Include', 1], ['Exclude', 0] ],
                       :selected => default)
  end

  # Generates HTML option tags for a dropdown of match conditions.
  #
  # @param [Integer] default the default selection, if applicable
  # @return [String] HTML option tags
  def options_for_conditions(default = nil)
    options_for_select([ ['Exactly Matches', 'equals'],
                         ['Containing', 'contains'],
                         ['Begins With', 'begins_with'],
                         ['Ends With', 'ends_with'],
                         ['Less Than', 'less_than'],
                         ['Greater Than', 'greater_than'] ],
                       :selected => default)
  end

  # Leverages the DisplayFieldValue special delimiter value
  # to display multiselect and checkbox responses on the
  # Edit SurveyResponse view.
  #
  # @param [String] plain string or delimited string
  # @return [String] plain string or HTML break-delimited string
  def split_multiple_answer_selections(answer_values)
    if answer_values.include?(DisplayFieldValue::VALUE_DELIMITER)
      answer_values.split(DisplayFieldValue::VALUE_DELIMITER).join("<br/>").html_safe
    else
      answer_values
    end
  end

  def previous_survey_response_link
    return unless @survey_responses.try(:size) > 0 && current_survey_response_location
    if current_survey_response_location == 0
      if @survey_responses.first_page?
        return
      else
        new_id = 'previous_page'
      end
    else
      new_id = @survey_responses[current_survey_response_location - 1].id
    end
    previous_path = edit_survey_response_path({
      id: new_id
    }.merge(params.slice(:simple_search, :survey_id, :survey_version_id))
    )
    link_to "Previous", previous_path
  end

  def next_survey_response_link
    if current_survey_response_location == @survey_responses.size - 1
      if @survey_responses.last_page?
        return
      else
        new_id = 'next_page'
      end
    else
      new_id = @survey_responses[current_survey_response_location + 1].id
    end
    next_path = edit_survey_response_path({
      id: new_id
    }.merge(params.slice(:simple_search, :survey_id, :survey_version_id))
    )
    link_to "Next", next_path
  end

  private

  def current_survey_response_location
    @current_survey_response_location ||= @survey_responses.index {|sr| sr.id.to_s == params[:id].to_s}
  end
end
