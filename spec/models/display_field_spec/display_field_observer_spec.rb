require 'spec_helper'

describe DisplayFieldObserver do
  pending "Is this functionality needed anymore?"
  
  it "should create display field values with the default values for existing survey versions"
  
  content "when calling after_destroy" do
    it "should destroy display_field_values which reference the destroyed display field"
    it "should destroy rules which have a criteria referencing this display field"
    it "should destroy rules which modify this display fields' display_field_values"
  end
end
