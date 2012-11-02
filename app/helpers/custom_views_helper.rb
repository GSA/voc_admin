module CustomViewsHelper
  def sort_orders(objs)
  	orders = ""

  	orders = objs.map {|obj| "#{obj.display_field_id}:#{obj.sort_direction}" }.join(',') unless objs.blank?
  end
end