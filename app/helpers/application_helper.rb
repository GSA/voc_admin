module ApplicationHelper

  # Dynamic method to build child records (e.g. ChoiceAnswers for a ChoiceQuestion)
  # via links on new/edit forms.  The partial created generates the form structure to support
  # POSTing back to create/update actions.
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new

    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(:partial => "shared/" + association.to_s.singularize + "_fields", :locals => {:f => builder, :survey_version => @survey_version, :survey => @survey})
    end

    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class=>"surveyNav")
  end

  # (see link_to_add_fields)
  # A variation on link_to_add_fields - specifically adding ChoiceAnswers to
  # ChoiceQuestions associated with the MatrixQuestion
  def link_to_add_matrix_answer(name)
    fields = render(:partial => "shared/matrix_answers_fields", :locals => {:i => "new_matrix_answer", :answer => nil})

    link_to_function(name, "add_matrix_answers(this, \"#{escape_javascript(fields)}\")", :class=>"surveyNav")
  end

  # Adds sort arrows to table columns
  def sortable(column, title = nil)
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"

    title ||= column.titleize

    arrows = content_tag :span, :class => "sort_arrows" do
      ret = ""
      ret += image_tag "arrow_up.png"   if direction == "desc" && column == params[:sort]
      ret += image_tag "arrow_down.png" if direction == "asc"  && column == params[:sort]
      ret.html_safe
    end

    title += arrows

    link_to title.html_safe, {:sort => column, :direction => direction}
  end
end
