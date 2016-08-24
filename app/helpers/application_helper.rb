# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# View helper repository for helpers used across functional areas of the application.
module ApplicationHelper

  def logout_link title:, classes: ""
    if Rails.env.development? || ENV['DEBUG_ACCESS'].present?
      link_to title, destroy_user_session_path, :class => "#{classes}"
    else
      link_to title, destroy_user_session_path, :class => "#{classes}"
    end
  end

  def nav_link_active_class controller, action=nil
    if controller == params[:controller] &&
        (action.blank? || action == params[:action])
      "navActive"
    else
      "nav"
    end
  end

  def manage_users_or_account_link
    html = ""
    html << "|"
    html << content_tag("p", class: "nav") do
      if @current_user.admin?
        link_to "Manage Users", users_url, class: nav_link_active_class("users"),
          title: "Manage Users"
      else
        link_to "Manage Account", edit_user_url(@current_user),
          class: nav_link_active_class("users"),
          title: "Manage Account"
      end
    end
    html.html_safe
  end

  # Dynamic method to build child records (e.g. ChoiceAnswers for a ChoiceQuestion)
  # via links on new/edit forms.  The partial created generates the form structure to support
  # POSTing back to create/update actions.
  #
  # @param [String] name the text to display within the generated link
  # @param [ActionView::Helpers::FormBuilder] f the FormBuilder from the view
  # @param [Symbol] association the child association of the FormBuilder's object
  # @return [String] HTML href link to add child records
  def link_to_add_fields(name, f, association, partial_name = nil)
    new_object = f.object.class.reflect_on_association(association).klass.new

    partial_name ||= "shared/" + association.to_s.singularize + "_fields"

    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(:partial => partial_name, :locals => {:f => builder, :survey_version => @survey_version, :survey => @survey})
    end

    link_to name, "javascript:void(0)", onclick: "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")",
      class: "newlink"
  end

  # (see link_to_add_fields)
  # A variation on link_to_add_fields - specifically adding ChoiceAnswers to
  # ChoiceQuestions associated with the MatrixQuestion.
  #
  # @param [String] name the text to display within the generated link
  # @return [String] HTML href link to add a ChoiceAnswer
  def link_to_add_matrix_answer(name)
    fields = render(:partial => "shared/matrix_answers_fields", :locals => {:i => "new_matrix_answer", :answer => nil})

    link_to name, "javascript:void(0);", onclick: "add_matrix_answers(this, \"#{escape_javascript(fields)}\")",
      class: "newlink"
  end

  # Adds sort arrow images to table DisplayField columns.
  #
  # @param [String] column the name of the column being sorted
  # @param [String] title optional alternate display text for the column
  # @return [String] HTML link for the column header text, with sort toggle information
  def sortable(column, title = nil, additional_params = {})
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"

    title ||= column.titleize

    arrows = content_tag :span, :class => "sort_arrows" do
      if column == params[:sort]
        if direction == "desc"
          image_tag "arrow_up_larger.png", :alt => "Sort"
        else
          image_tag "arrow_down_larger.png", :alt => "Sort"
        end
      else
        image_tag "arrows.png", :alt => "Sort"
      end
    end

    title += arrows

    link_to title.html_safe, additional_params.merge(
      {:sort => column, :direction => direction}
    )
  end

  def get_reporting_link(survey, version)
    link_to image_tag('report.png', :alt=>"view reports"), reporting_survey_survey_version_path(:id => version.id, :survey_id => survey.id) if version && version.reporters.count > 0 && version.survey_responses.count > 0
  end

  def pdf?
    params[:action] == 'pdf'
  end

  def required_label(label_text)
    "<abbr title='required'>*</abbr>#{label_text}".html_safe
  end
end
