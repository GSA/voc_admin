# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# View helper repository for helpers used across functional areas of the application.
module ApplicationHelper

  # Dynamic method to build child records (e.g. ChoiceAnswers for a ChoiceQuestion)
  # via links on new/edit forms.  The partial created generates the form structure to support
  # POSTing back to create/update actions.
  # 
  # @param [String] name the text to display within the generated link
  # @param [ActionView::Helpers::FormBuilder] f the FormBuilder from the view
  # @param [Symbol] association the child association of the FormBuilder's object
  # @return [String] HTML href link to add child records
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new

    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(:partial => "shared/" + association.to_s.singularize + "_fields", :locals => {:f => builder, :survey_version => @survey_version, :survey => @survey})
    end

    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class=>"newlink")
  end

  # (see link_to_add_fields)
  # A variation on link_to_add_fields - specifically adding ChoiceAnswers to
  # ChoiceQuestions associated with the MatrixQuestion.
  # 
  # @param [String] name the text to display within the generated link
  # @return [String] HTML href link to add a ChoiceAnswer
  def link_to_add_matrix_answer(name)
    fields = render(:partial => "shared/matrix_answers_fields", :locals => {:i => "new_matrix_answer", :answer => nil})

    link_to_function(name, "add_matrix_answers(this, \"#{escape_javascript(fields)}\")", :class=>"newlink")
  end

  # Adds sort arrow images to table DisplayField columns.
  # 
  # @param [String] column the name of the column being sorted
  # @param [String] title optional alternate display text for the column
  # @return [String] HTML link for the column header text, with sort toggle information
  def sortable(column, title = nil)
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"

    title ||= column.titleize

    arrows = content_tag :span, :class => "sort_arrows" do
      ret = ""
      if column == params[:sort]
        ret += image_tag "arrow_up_larger.png", :alt => "Sort"   if direction == "desc" && column == params[:sort]
        ret += image_tag "arrow_down_larger.png", :alt => "Sort" if direction == "asc"  && column == params[:sort]
      else
        ret += image_tag "arrows.png", :alt => "Sort"
      end
      ret.html_safe
    end

    title += arrows

    link_to title.html_safe, {:sort => column, :direction => direction}
  end

  def get_reporting_link(survey, version)
    link_to image_tag('report.png', :alt=>"view reports"), reporting_survey_survey_version_path(:id => version.id, :survey_id => survey.id) if version && version.reporters.count > 0 && version.survey_responses.count > 0
  end

  def pdf?
    params[:action] == 'pdf'
  end
end
