require "rails_helper"

RSpec.describe User, type: :model do
  context "#validations" do
    it { should validate_presence_of(:f_name) }
    it { should validate_presence_of(:l_name) }
  end

  context ".search" do
    it "should return users with matching first names" do
      create(:user, f_name: "John", l_name: "Doe")
      expect(User.search("John").map(&:f_name)).to eq ["John"]
    end

    it "returns users with matching last names" do
      create :user, l_name: "Example"
      expect(User.search("Example").map(&:l_name)).to eq ["Example"]
    end

    it "matches full names" do
      create :user, f_name: "John", l_name: "Doe"
      expect(User.search("John Doe").count).to eq 1
    end

    it "matches case insensitive" do
      create :user, f_name: "John"
      expect(User.search("john").count).to eq 1
    end

    it "does not include non-matching results" do
      create :user, f_name: "John", l_name: "Denver"
      expect(User.search("john doe").count).to eq 0
    end

  end
end
