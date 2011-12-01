class FixElementOrders < ActiveRecord::Migration
  def self.up
    Page.all.each do |page|
      SurveyElement.compact_element_order(page)
    end
  end

  def self.down
  end
end
