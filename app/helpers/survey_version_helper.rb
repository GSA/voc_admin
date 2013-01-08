# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# View helpers for SurveyResponse functionality.
module SurveyVersionHelper

  # Generates the page-level div tags for the SurveyVersion preview ("show") page
  #
  # @param [Page] page the Page instance to test
  # @param [Hash] params a Hash of request params, used to determine current page
  # @return [String] an HTML div tag with appropriate id and stylings
  def get_page_div_tag( page, params )
    options = Hash.new

    hidden = page.page_number != (params[:page].present? ? params[:page].to_i : 1)

    options["id"] = "page_#{page.page_number}"
    options["class"] = hidden ? 'hidden_page' : 'current_page'
    options["style"] = "display: none" if hidden

    tag("div", options, true)
  end

  # Tests to determine if the given page is last in the SurveyVersion; used for
  # visibility of the page-level flow control dropdown.
  #
  # @param [Page] page the Page instance to test
  # @return [Boolean] true if last page; false if not
  def is_last_page(page)
    Page.where(:survey_version_id => page.survey_version_id).where("pages.page_number > ?", page.page_number).empty? and page.next_page_id.nil?
  end

  # Generates a dropdown to specify the next page for flow control purposes.
  # Note: since "Next Page" (+1) is default, numbering starts at current + 2
  # 
  # @param [Page] page the Page instance to use
  # @return [String] HTML select and child option tags
  def select_for_next_page(page)
    select_tag(
      :next_page,
      options_for_select(
        [["Next Page", ""]] + 
        Page.where(:survey_version_id => page.survey_version_id)
            .where("pages.page_number > ?", page.page_number + 1)
            .order(:page_number).collect { |p| [ "Pg. #{p.page_number}", p.id ] },
        page.next_page_id
      ),
      :include_blank => false,
      :id => "next_page_#{page.page_number}",
      :class => "NextPageSelect",
      :name => "next_page",
      "data-url" => survey_survey_version_page_path(page.survey_version.survey, page.survey_version, page)
    )
  end

  # Assembles links for reordering pages.
  # 
  # @param [Survey] survey the Survey instance
  # @param [SurveyVersion] survey_version the SurveyVersion instance
  # @param [Page] page the Page instance
  # @return [String] assembled HTML links
  def page_order_links(survey, survey_version, page)
    str = generate_page_up_arrow_link( move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number - 1)) )

    str += generate_page_down_arrow_link( move_page_survey_survey_version_page_path(survey, survey_version, page, :page_number => (page.page_number + 1)) )
  end

  # Assembles links for copying and deleting pages.
  # 
  # @param [Survey] survey the Survey instance
  # @param [SurveyVersion] survey_version the SurveyVersion instance
  # @param [Page] page the Page instance
  # @return [String] assembled HTML links
  def page_management_links(survey, survey_version, page)
		str = generate_page_copy_link( copy_page_survey_survey_version_page_path(survey, survey_version, page) )

		str += generate_page_delete_link( survey_survey_version_page_path(survey, survey_version, page), page.page_number )
  end

  # Assembles links for reordering questions and other survey content.
  # 
  # @param [Survey] survey the Survey instance
  # @param [SurveyVersion] survey_version the SurveyVersion instance
  # @param [SurveyElement] element the SurveyElement instance
  # @return [String] assembled HTML links
  def element_order_links(survey, survey_version, element)
    confirm_move_msg = "This action will remove the flow control from this question. Continue?"

    str = generate_element_move_up_link( up_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element),
                                          confirm_element_move_up(element) ? confirm_move_msg : nil )

    str += generate_element_move_down_link( down_survey_survey_version_survey_element_path(survey_version.survey, survey_version, element),
                                            confirm_element_move_down(element) ? confirm_move_msg : nil )
  end

  # Assembles a link for editing a question or other survey content.
  # 
  # @param [Survey] survey the Survey instance
  # @param [SurveyVersion] survey_version the SurveyVersion instance
  # @param [SurveyElement] element the SurveyElement instance
  # @return [String] the assembled HTML link
  def element_edit_link(survey, survey_version, element)
    generate_element_edit_link( url_for([:edit, survey, survey_version, element.assetable]) )
  end

  # Assembles a link for deleting a question or other survey content.
  # 
  # @param [Survey] survey the Survey instance
  # @param [SurveyVersion] survey_version the SurveyVersion instance
  # @param [SurveyElement] element the SurveyElement instance
  # @return [String] the assembled HTML links
  def element_delete_link(survey, survey_version, element)
    generate_element_delete_link( url_for([survey, survey_version, element.assetable]) )
  end

  # Uses question properties to set onclick events for flow control and
  # jumping to the next page upon response.
  #
  # @param [ChoiceQuestion] element the ChoiceQuestion instance
  # @param [Page] page the Page instance
  # @param [ChoiceAnswer] answer the ChoiceAnswer instance
  # @return [String] the JS to attach to the HTML element's onclick attribute
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

  # Create the page move up link.
  #
  # @param [String] url the target of the link
  # @return [String] the link-wrapped image HTML
  def generate_page_up_arrow_link(url)
    link_to image_tag("arrow_up.png", :alt => "move up"),
            url,
            { :method => :post,
              :remote => true,
              :title => "Move this page up in presentation order.",
              :class => "upLink" }
  end

  # Create the page move down link.
  #
  # @param [String] url the target of the link
  # @return [String] the link-wrapped image HTML
  def generate_page_down_arrow_link(url)
    link_to image_tag("arrow_down.png", :alt => "move down"),
            url,
            { :method => :post, 
              :remote => true,
              :title => "Move this page down in presentation order.", 
              :class => "downLink" }
  end

  # Create the page copy link.
  #
  # @param [String] url the target of the link
  # @return [String] the HTML link
  def generate_page_copy_link(url)
    link_to image_tag("clone.png", :alt=>"Copy Page"),
            url,
            { :method => :post,
              :remote => true,
              :class => "copyLink",
              :title => "Create a copy of this page." }
  end

  # Create the page delete link.
  #
  # @param [String] url the target of the link
  # @return [String] the HTML link
  def generate_page_delete_link(url, page_number)
    link_to image_tag('delete.png', :alt=>"Delete"),
            url,
            { :method => :delete,
              :remote => true,
              :title => "Remove page",
              :class=>"deleteLink",
              :confirm => "All items on page #{page_number} will be removed as well." }
  end

  # Create the element edit link.
  #
  # @param [String] url the target of the link
  # @return [String] the link-wrapped image HTML
  def generate_element_edit_link(url)
    link_to image_tag('edit.png', :alt=>"edit"),
            url,
            { :method => :get,
              :remote => true,
              :title => "Edit the questions and other survey content on the page.",
              :class => "edit_asset_link" }
  end

  # Create the element move up link.
  #
  # @param [String] url the target of the link
  # @param [String] confirm_move_msg a message to present to the user to confirm (because we're breaking flow control)
  # @return [String] the link-wrapped image HTML
  def generate_element_move_up_link(url, confirm_move_msg)
    link_to image_tag("arrow_up.png", :alt => "move up"),
            url,
            { :method => :post,
              :remote => true,
              :title => "Move up",
              :class => "element_order_up",
              :confirm => confirm_move_msg }
  end

  # Create the element move down link.
  #
  # @param [String] url the target of the link
  # @param [String] confirm_move_msg a message to present to the user to confirm (because we're breaking flow control)
  # @return [String] the link-wrapped image HTML
  def generate_element_move_down_link(url, confirm_move_msg)
    link_to image_tag("arrow_down.png", :alt => "move down"),
            url,
            { :method => :post,
              :remote => true,
              :title => "Move down",
              :class => "element_order_up",
              :confirm => confirm_move_msg }
  end

  # Create the element delete link.
  #
  # @param [String] url the target of the link
  # @return [String] the HTML link
  def generate_element_delete_link(url)
    link_to image_tag("delete.png", :alt=>"Delete"),
            url,
            { :method => :delete,
              :remote => true,
              :title => "Delete page element",
              :class=>"deleteLink",
              :confirm => "Are you sure?" }
  end

  # Detects whether a question contains flow control and moving it up would
  # relocate it to the previous page.
  #
  # @param [SurveyElement] element the SurveyElement instance to test
  # @return [Boolean] the evaluated value
  def confirm_element_move_up(element)
    element.assetable_type == "ChoiceQuestion" &&
    element.assetable.question_content.flow_control &&
    element.element_order == 1
  end

  # Detects whether a question contains flow control and moving it down would
  # relocate it to the next page.
  #
  # @param [SurveyElement] element the SurveyElement instance to test
  # @return [Boolean] the evaluated value
  def confirm_element_move_down(element)
    element.assetable_type == "ChoiceQuestion" &&
    element.assetable.question_content.flow_control &&
    element.element_order.to_i == element.page.survey_elements.maximum(:element_order).to_i
  end
end
