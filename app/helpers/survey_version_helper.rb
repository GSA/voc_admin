module SurveyVersionHelper
  
  def page_management_links(survey, survey_version, page)
		str = link_to image_tag("arrow_up.png", :alt=>"Up Arrow") + "<span class='link_text'>Move Page Up</span>".html_safe, move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number - 1)), :method => :post, :remote => true, :class => "move_page_up"
		str += link_to image_tag("arrow_down.png", :alt=>"Down Arrow") + "<span class='link_text'>Move Page Down</span>".html_safe, move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number + 1)), :method => :post, :remote => true, :class => "move_page_down"
		str += link_to image_tag("copy.png", :alt=>"Copy Page", :class=>"copy_page") + "<span class='link_text'>Copy Page</span>".html_safe, copy_page_survey_survey_version_page_path(survey, survey_version, page), :method => :post, :title=>"Create a copy of this page.", :remote => true, :class=>"copy_page"
		str += link_to image_tag("red_x.png", :alt=>"Delete Page", :class=>"redXpage") + "<span class='link_text'>Delete Page</span>".html_safe, survey_survey_version_page_path(survey, survey_version, page), :remote => true, :method => :delete, :confirm => "All items on page #{page.page_number} will be removed as well.", :class => "remove_page_link", :title => "Remove page"    
  end
  
  def element_management_links(survey, survey_version, element)
    confirm_move_msg = "This action will remove the flow control from this question. Continue?"
    str = link_to image_tag("edit.png", :alt=>"Edit Page", :class=>"copy_page") + "<span class='link_text'>Edit</span>".html_safe, url_for([:edit, survey, survey_version, element.assetable]), :remote => true, :class => "edit_asset_link"
      
    confirm_move = element.assetable_type == "ChoiceQuestion" && element.assetable.question_content.flow_control && element.element_order == 1
    str += link_to image_tag("arrow_up.png", :alt=>"Up Arrow") + "<span class='link_text'>Move Up</span>".html_safe, up_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element),
				:method => :post, :remote => true, :class => "element_order_up", :title => "Move up", :confirm => (confirm_move ? confirm_move_msg : nil)
				
		confirm_move = element.assetable_type == "ChoiceQuestion" && element.assetable.question_content.flow_control && element.element_order.to_i == element.page.survey_elements.maximum(:element_order).to_i
    str += link_to image_tag("arrow_down.png", :alt=>"Down Arrow") + "<span class='link_text'>Move Down</span>".html_safe, 
				down_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element), :method => :post, :remote => true,
				:class => "element_order_up", :title => "Move down", :confirm => (confirm_move ? confirm_move_msg : nil)
				  
		str +=link_to image_tag("red_x.png", :alt=>"Delete Element", :class=>"redX") + "<span class='link_text'>Delete</span>".html_safe, 
				url_for([survey, survey_version, element.assetable]), :method => :delete, :confirm => "Are you sure?",
				:remote => true, :class => "remove_question_link", :title => "Delete page element"
  end
  
  def generate_onclick(element, page, answer)
    onclick = ""
    if element.assetable.question_content.flow_control
      onclick += "set_next_page(#{page.page_number}, #{answer.page.try(:page_number) || (element.page.page_number + 1)});"
    end
    
    if element.assetable.auto_next_page
      onclick += "show_next_page(#{page.page_number});"
    end
    
    onclick
  end
end
