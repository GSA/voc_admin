require "rails_helper"

RSpec.describe MatrixQuestion do
  it { should validate_presence_of(:question_content) }
end
