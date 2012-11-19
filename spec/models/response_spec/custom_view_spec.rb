require 'spec_helper'
include SurveyHelpers

describe CustomView do
  before(:each) do 
    @sv = create :survey_version, :major => 1, :minor => 1
  end

  context "validations" do
    ## Test validations using shoulda-matchers
    it { should validate_uniqueness_of(:name).scoped_to(:survey_version_id) }

    it { should validate_presence_of(:name).with_message(/can't be blank/) }

    it { should validate_presence_of(:survey_version) }

    it { should ensure_length_of(:name).is_at_most(255) }
  end

  context "validate unique true :default" do
    it "should allow multiple non-default views" do
      cv1 = create :custom_view, :survey_version => @sv
      cv2 = build :custom_view, :survey_version => @sv

      cv2.should be_valid
    end

    it "should reject multiple default views" do
      CustomView.any_instance.stub(:update_default_fields)

      cv1 = create :custom_view, :survey_version => @sv, :default => true
      cv2 = build :custom_view, :survey_version => @sv, :default => true

      cv2.should_not be_valid
    end
  end

  context "before_validation :update_default_fields filter" do
    it "should ensure :update_default_fields is called" do
      CustomView._validation_callbacks.select{|cb| cb.kind.eql?(:before)}.collect(&:filter).should include(:update_default_fields)
    end

    it "should reset all DB defaults to false for survey_version" do
      cv1 = create :custom_view, :survey_version => @sv, :default => true
      cv2 = create :custom_view, :survey_version => @sv, :default => true
      cv3 = create :custom_view, :survey_version => @sv, :default => true

      CustomView.where(:survey_version_id => @sv.id, :default => true).length.should eq(1)
    end
  end

  context "ordered_display_fields" do
    before(:each) do
      setup_custom_view
    end

    it "should take a list of display fields without sort information" do
      @cv.ordered_display_fields = { 'selected' => @dfids.reverse.join(','), 'sorts' => '' }

      @cv.ordered_display_fields.map{ |df| df.id }.should eq(@dfids.reverse);
    end

    it "should take a list of display fields and sort information" do
      @cv.ordered_display_fields = { 'selected' => @dfids.reverse.join(','), 'sorts' => @dfids.map {|d| "#{d}:asc" } }

      @cv.ordered_display_fields.map{ |df| df.id }.should eq(@dfids.reverse);
    end
  end

  context "sorted_display_field_custom_views" do
    before(:each) do
      setup_custom_view
    end

    it "should return join records in sort order, with direction" do
      directions = ['desc','asc','desc']
      @cv.ordered_display_fields = { 'selected' => @dfids.reverse.join(','),
                                     'sorts' => @dfids.zip(directions).map {|a,b| "#{a}:#{b}"}.join(',') }

      dfcvs = @cv.sorted_display_field_custom_views
      dfcvs.map { |dfcv| dfcv.display_field_id }.should eq(@dfids)
      dfcvs.map { |dfcv| dfcv.sort_direction }.should eq(directions)
    end
  end

  def setup_custom_view
    publish_survey_version

    @cv = @v.custom_views.create! :name => 'test CustomView', :default => true

    @dfids = @v.display_fields.map { |dft| dft.id }
  end
end
