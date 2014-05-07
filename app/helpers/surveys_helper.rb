# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# View helpers for SurveyResponse functionality.
module SurveysHelper

  # For a given ChoiceQuestion with flow control at the ChoiceAnswer level,
  # generates the Javascript logic to enforce correct page switching.
  #
  # @param [ChoiceQuestion] element the ChoiceQuestion instance
  # @return [String] the generated Javascript code
  def generate_next_page_on_change(element)
    q_content = element.assetable.question_content
    return "" unless q_content.flow_control

    q_answers = element.assetable.choice_answers

    change_function = q_answers.map {|answer| "if($(this).val() == \"#{answer.id}\"){$('#page_'+#{element.page.page_number}+'_next_page').val(\"#{answer.next_page_id.nil? ? (element.page.page_number + 1) : answer.page.page_number}\")}"}.join(';')
  end

  def sorted_site_list
    site_scope = current_user.admin? ? Site : current_user.sites
    site_scope.order("name asc")
  end

  def invitation_accept_button_text
    if @survey.invitation_accept_button_text.blank?
      "Yes"
    else
      @survey.invitation_accept_button_text
    end
  end

  def invitation_reject_button_text
    if @survey.invitation_reject_button_text.blank?
      "No"
    else
      @survey.invitation_reject_button_text
    end
  end

  def start_screen_button_text
    if @survey.start_screen_button_text.blank?
      "Start"
    else
      @survey.start_screen_button_text
    end
  end
end
