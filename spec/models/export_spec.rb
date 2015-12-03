require "rails_helper"

RSpec.describe Export do
  context "validations" do
    before(:each) { allow_any_instance_of(Export).to receive(:generate_access_token) }
    it { should validate_presence_of(:access_token) }
    it { should validate_uniqueness_of(:access_token) }
    it { should validate_length_of(:access_token).is_at_most(255) }
  end

  context "#active" do
    it "returns exports created within the last 25 hours" do
      new = create :export, created_at: 20.hours.ago
      create :export, created_at: 26.hours.ago
      expect(Export.active).to eq [new]
    end
  end

end
