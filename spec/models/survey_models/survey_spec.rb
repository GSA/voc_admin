require "rails_helper"

RSpec.describe Survey, type: :model do
  describe "Validations" do
    subject { FactoryGirl.build :survey }

    # Name
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_uniqueness_of(:name) }

    # Description
    it { should validate_presence_of(:description) }
    it { should validate_length_of(:description).is_at_most(65535) }

    # Site association
    it { should belong_to(:site) }
    it { should validate_presence_of(:site) }

    # Invitation Percentage
    it { should validate_presence_of(:invitation_percent) }
    it { should validate_numericality_of(:invitation_percent).only_integer.
         is_greater_than_or_equal_to(0).
         is_less_than_or_equal_to(100) }

    # Invitation Interval
    it { should validate_presence_of(:invitation_interval) }
    it { should validate_numericality_of(:invitation_interval).only_integer.
        is_greater_than_or_equal_to(0) }

    # Alarm Notification Email
    it { should_not validate_presence_of(:alarm_notification_email) }

    context "alarm is true" do
      subject { build :survey, alarm: true }

      it { should validate_presence_of(:alarm_notification_email) }
    end

    # js_require_fields_error
    it { should validate_length_of(:js_required_fields_error).is_at_most(255) }

    it { should validate_length_of(:previous_page_text).is_at_most(255) }
    it { should validate_length_of(:next_page_text).is_at_most(255) }
    it { should validate_length_of(:submit_button_text).is_at_most(255) }
  end #Validations

  context "after_create callback" do
    let(:survey) { build :survey }
    it "calls create_new_major_version" do
      expect(survey).to receive(:create_new_major_version)
      survey.save
    end

    it "is not called on update" do
      survey.save # Save the survey to the database to trigger the create before
                  # the expecation is set.
      expect(survey).to_not receive(:create_new_major_version)
      survey.save # Trigger an update since the survey is already saved.
    end
  end #after_create callback

  context "#published_version" do
    let(:survey) { create :survey }

    context "with no published versions" do
      it "should return nil" do
        expect(survey.published_version).to be nil
      end
    end

    context "with a single published version" do
      let!(:published_version) { survey.create_new_minor_version.tap do |version|
          version.update_attribute :published, true
        end
      }

      it "should return the currently published version" do
        expect(survey.published_version).to eq published_version
      end
    end
  end #published_version

  context "#newest_version" do
    it "returns the version with the highest major version" do
      survey = create :survey
      new_version = survey.survey_versions.create major: 2, minor: 0
      expect(survey.newest_version).to eq new_version
    end

    it "returns the version with the highest minor version of those with the highest major version" do
      survey = create :survey
      new_version = survey.survey_versions.create major: 2, minor: 0
      survey.survey_versions.create major: 1, minor: 1
      expect(survey.newest_version).to eq new_version
    end

  end
end
