require "rails_helper"

RSpec.describe Survey, type: :model do
  describe "Validations" do
    subject { FactoryGirl.build :survey }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_length_of(:description).is_at_most(65535) }
    it { should belong_to(:site) }
    it { should validate_presence_of(:site) }

    # Invitation Percentage
    it { should validate_presence_of(:invitation_percent) }
    it { should validate_numericality_of(:invitation_percent).only_integer.
         is_greater_than_or_equal_to(0).
         is_less_than_or_equal_to(100) }
   it { should validate_presence_of(:invitation_interval) }
   it { should validate_numericality_of(:invitation_interval).only_integer.
        is_greater_than_or_equal_to(0) }


  end
end
