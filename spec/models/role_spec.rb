require 'spec_helper'

describe Role do

  context "validations" do
    it { should validate_presence_of(:name).with_message(/can't be blank/) }
    it { should validate_uniqueness_of(:name).with_message(/has already been taken/)}
  end

end
