# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# View helpers for CustomView functionality.
module CustomViewsHelper

  # This function is used when rendering sort selections to the new/edit
  # Custom View flows.  Renders a string like "7:asc,13:desc,4:asc", which
  # is interpreted by the Javascript on the page.
  #
  # @param [Array<DisplayFieldCustomView>] objs objects containing DisplayField id and sort direction info
  # @return [String] comma-delimited pairings of id and direction 
  def sort_orders(objs)
    sorts = params[:custom_view].try(:[], :ordered_display_fields).try(:[], :sorts)
    return sorts if sorts
    orders = ""
    orders = objs.map {|obj| "#{obj.display_field_id}:#{obj.sort_direction}" }.join(',') unless objs.blank?
  end
end
