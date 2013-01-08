# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Layout functionality provided by
# {https://github.com/ryanb/nifty-generators Nifty Generators}
# and included here verbatim.

# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def flash_messages(flash)
    unless flash.empty?
	    content_tag :div, :class => (controller_name == "user_sessions" ? "flash_location_login" : "flash_location_upper") do
	      content = ""
	      flash.each do |name, msg|
	        content << content_tag(:p, msg, :id => "flash_#{name}" )
	      end
	      content.html_safe
	    end
	  end
  end
end
