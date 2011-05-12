module ApplicationHelper
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(:partial => "shared/" + association.to_s.singularize + "_fields", :locals => {:f => builder, :survey_version => @survey_version, :survey => @survey})
    end
    
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class=>"surveyNav")
  end
  
  def link_to_add_matrix_answer(name)
    fields = render(:partial => "shared/matrix_answers_fields", :locals => {:i => "new_matrix_answer"})
    
    link_to_function(name, "add_matrix_answers(this, \"#{escape_javascript(fields)}\")")
  end
end
