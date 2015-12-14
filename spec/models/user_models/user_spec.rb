require "rails_helper"

RSpec.describe User, type: :model do
  context "#validations" do
    it { should validate_presence_of(:f_name) }
    it { should validate_presence_of(:l_name) }
    it { should validate_presence_of(:hhs_id) }
    it { should validate_numericality_of(:hhs_id).only_integer }
    it { should validate_length_of(:hhs_id).is_equal_to(10) }
  end
end
