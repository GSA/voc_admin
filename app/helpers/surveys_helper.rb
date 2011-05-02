module SurveysHelper
  
  def generate_next_page_on_change(element)
    q_content = element.assetable.question_content
    return "" unless q_content.flow_control
    
    q_answers = element.assetable.choice_answers
    
    change_function = q_answers.map {|answer| "if($(this).val() == \"#{answer.id}\"){$('#page_'+#{element.page.number}+'_next_page').val(\"#{answer.next_page_id.nil? ? (element.page.number + 1) : answer.page.number}\")}"}.join(';')
    
#    
#    change_function = q_answers.inject do |memo, answer|
#      memo.concat("if($(this).val() == \"#{answer.id}\"){$('#page_'+#{element.page.number}+'_next_page').val(\"#{answer.next_page_id.nil? ? (element.page.number + 1) : answer.page.number}\")};")
#    end
  end
end
