module SurveyVersionHelper

  # assembles links for moving, copying, and deleting pages
  def page_management_links(survey, survey_version, page)
		str = generate_page_up_arrow_link( move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number - 1)) )

		str += generate_page_down_arrow_link( move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number + 1)) )

		str += generate_page_copy_link( copy_page_survey_survey_version_page_path(survey, survey_version, page) )

		str += generate_page_delete_link( survey_survey_version_page_path(survey, survey_version, page), page.page_number )
  end

  # assembles links for editing, moving, and deleting survey questions
  # and other content
  def element_management_links(survey, survey_version, element)
    confirm_move_msg = "This action will remove the flow control from this question. Continue?"

    str = generate_element_edit_link( url_for([:edit, survey, survey_version, element.assetable]) )

    str += generate_element_move_up_link( up_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element),
                                          confirm_element_move_up(element) ? confirm_move_msg : nil )

    str += generate_element_move_down_link( down_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element),
                                            confirm_element_move_down(element) ? confirm_move_msg : nil )

    str += generate_element_delete_link( url_for([survey, survey_version, element.assetable]) )
  end

  # uses question properties to set onclick events for flow control and
  # jumping to the next page upon response
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

  # generate each link using the context-appropriate data; the first group of
  # parameters defines the image and text span, second group is for the
  # link that wraps them

  def generate_page_up_arrow_link(url)
    generate_image_link "arrow_up.png",
                        { :alt => "Up Arrow" },
                        "Move Page Up",

                        url,
                        { :method => :post,
                          :title => "Move this page up in presentation order.",
                          :class => "move_page_up" }
  end

  def generate_page_down_arrow_link(url)
    generate_image_link "arrow_down.png",
                        { :alt => "Down Arrow" },
                        "Move Page Down",

                        url,
                        { :method => :post, 
                          :title => "Move this page down in presentation order.", 
                          :class => "move_page_down" }
  end

  def generate_page_copy_link(url)
    generate_image_link "copy.png",
                        { :alt => "Copy Page",
                          :class => "copy_page" }, 
                        "Copy Page",

                        url,
                        { :method => :post,
                          :title => "Create a copy of this page.",
                          :class => "copy_page" }
  end

  def generate_page_delete_link(url, page_number)
    generate_image_link "red_x.png",
                        { :alt => "Delete Page",
                          :class => "redXpage" },
                        "Delete Page",

                        url,
                        { :method => :delete,
                          :title => "Remove page",
                          :class => "remove_page_link",
                          :confirm => "All items on page #{page_number} will be removed as well." }
  end

  def generate_element_edit_link(url)
    generate_image_link "edit.png",
                        { :alt => "Edit Element",
                          :class => "copy_page" },
                        "Edit",

                        url,
                        { :method => :get,
                          :title => "Edit the questions and other survey content on the page.",
                          :class => "edit_asset_link" }
  end

  def generate_element_move_up_link(url, confirm_move_msg)
    generate_image_link "arrow_up.png",
                        { :alt => "Up Arrow" },
                        "Move Up",

                        url,
                        { :method => :post,
                          :title => "Move up",
                          :class => "element_order_up",
                          :confirm => confirm_move_msg }
  end

  def generate_element_move_down_link(url, confirm_move_msg)
    generate_image_link "arrow_down.png",
                        { :alt => "Down Arrow" },
                        "Move Down",

                        url,
                        { :method => :post,
                          :title => "Move down",
                          :class => "element_order_up",
                          :confirm => confirm_move_msg }
  end

  def generate_element_delete_link(url)
    generate_image_link "red_x.png",
                        { :alt => "Delete Element",
                          :class => "redX" },
                        "Delete",

                        url,
                        { :method => :delete,
                          :title => "Delete page element",
                          :class => "remove_question_link",
                          :confirm => "Are you sure?" }
  end

  # creates an image with accompanying text, wrapped in a link
  def generate_image_link(image, image_opts, link_text, url, link_opts)
    link_to generate_image_tag_and_link(image, image_opts, link_text), url, link_opts.merge(:remote => true)
  end

  # builds the image-and-text portion of generate_image_link
  def generate_image_tag_and_link(image, image_opts, link_text)
    image_tag(image, image_opts) + "<span class='link_text'>#{link_text}</span>".html_safe
  end

  # returns true if a question contains flow control and moving it up would
  # relocate it to the previous page
  def confirm_element_move_up(element)
    element.assetable_type == "ChoiceQuestion" &&
    element.assetable.question_content.flow_control &&
    element.element_order == 1
  end

  # returns true if a question contains flow control and moving it up would
  # relocate it to the next page
  def confirm_element_move_down(element)
    element.assetable_type == "ChoiceQuestion" &&
    element.assetable.question_content.flow_control &&
    element.element_order.to_i == element.page.survey_elements.maximum(:element_order).to_i
  end
end
