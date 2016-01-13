require "rails_helper"

RSpec.describe Asset, type: :model do
  it { should validate_presence_of(:snippet) }

  context ".clone_me" do
    it "adds the asset to the target survey version" do

    end
  end
end
