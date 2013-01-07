require 'spec_helper'

describe Export do
  context "basic validations" do
    before(:each) do
      Export.any_instance.stub(:generate_access_token)
      @export = build :export, access_token: "abcdef0123456789"
    end

    it "should be valid" do
      @export.should be_valid
    end

    it "should not be valid without an access_token" do
      @export.access_token = nil
      @export.should_not be_valid
      @export.errors[:access_token].should include("can't be blank")
    end

    it "should not be valid without a unique access_token" do
      export2 = create :export, access_token: "abcdef0123456789"
      @export.should_not be_valid
      @export.errors[:access_token].should include("has already been taken")
    end

    it "should not be valid with an access_token longer than 255 characters" do
      @export.access_token = "a" * 256
      @export.should_not be_valid
      @export.errors[:access_token].should include("is too long (maximum is 255 characters)")
    end

    it "should not be valid without an attached document" do
      @export.document = nil
      @export.should_not be_valid
      @export.errors[:document].should include("can't be blank")
    end
  end

  context "before_validation checking" do
    it "should ensure generate_access_token is a before_validation filter" do
      Export._validation_callbacks.select{|cb| cb.kind.eql?(:before)}.collect(&:filter).should include(:generate_access_token)
    end

    it "should receive generate_access_token" do
      export = build :export

      export.should_receive(:generate_access_token)

      export.save!
    end
  end

  context "generate_access_token" do
    it "should set access_token" do
      export = build :export, :access_token => nil
      export.instance_eval("generate_access_token")

      export.access_token.should_not be_nil
      export.should be_valid
    end
  end
end