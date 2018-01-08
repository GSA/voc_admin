class AddReferrerAndUserAgentToSurveyResponses < ActiveRecord::Migration
  def change
    add_column :survey_responses, :referrer, :string
    add_column :survey_responses, :user_agent, :string
  end
end
