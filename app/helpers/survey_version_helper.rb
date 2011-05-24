module SurveyVersionHelper
  
  def page_management_links(survey, survey_version, page)
		str = link_to image_tag("arrow_up.png", :alt=>"Up Arrow"), move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number - 1)), :method => :post, :remote => true, :class => "move_page_up"
		str += link_to image_tag("arrow_down.png", :alt=>"Down Arrow"), move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number + 1)), :method => :post, :remote => true, :class => "move_page_down"
		str += link_to image_tag("red_x.png", :alt=>"Remove Page"), survey_survey_version_page_path(survey, survey_version, page), :remote => true, :method => :delete, :confirm => "All items on page #{page.page_number} will be removed as well.", :class => "remove_page_link", :title => "Remove page"    
  end
  
  def element_management_links(survey, survey_version, element)
    str = link_to "Edit", url_for([:edit, survey, survey_version, element.assetable]), :remote => true, :class => "edit_asset_link"
    str += link_to image_tag("arrow_up.png", :alt=>"Up Arrow"), up_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element),
				:method => :post, :remote => true, :class => "element_order_up", :title => "Move up" 
    str += link_to image_tag("arrow_down.png", :alt=>"Down Arrow"), 
				down_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element), :method => :post, :remote => true,
				:class => "element_order_up", :title => "Move down" 
		str +=link_to image_tag("red_x.png", :alt=>"Remove Element"), 
				url_for([survey, survey_version, element.assetable]), :method => :delete, :confirm => "Are you sure?",
				:remote => true, :class => "remove_question_link", :title => "Remove page element"   
  end
end
