require "rails_helper"

RSpec.describe SurveyVersion do
  it { should validate_presence_of(:major) }
  it { should validate_presence_of(:minor) }
  it { should validate_numericality_of(:major) }
  it { should validate_presence_of(:survey) }
end
