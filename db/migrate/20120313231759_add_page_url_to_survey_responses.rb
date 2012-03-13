class AddPageUrlToSurveyResponses < ActiveRecord::Migration
  def self.up
    add_column :survey_responses, :page_url, :text
  end

  def self.down
    remove_column :survey_responses, :page_url
  end
end
