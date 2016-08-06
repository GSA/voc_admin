require "rails_helper"

RSpec.describe SurveyVersion do
  it { should validate_presence_of(:major) }
  it { should validate_presence_of(:minor) }
  it { should validate_numericality_of(:major) }
  it { should validate_presence_of(:survey) }

  context "Reporting caches" do
    it "increments the temp count for today by 1" do
      survey_version = FactoryGirl.create(:survey_version)
      expect(survey_version.temp_visit_count[date_string]).to eq nil

      survey_version.increment_temp_visit_count

      expect(survey_version.temp_visit_count[date_string]).to eq "1"
    end

    it "increments the temp count for invitations today by 1" do
      survey_version = FactoryGirl.create(:survey_version)
      expect(survey_version.temp_invitation_count[date_string]).to eq nil

      survey_version.increment_temp_invitation_count

      expect(survey_version.temp_invitation_count[date_string]).to eq "1"
    end

    it "increments the temp count for invitation_accepted by 1" do
      survey_version = FactoryGirl.create(:survey_version)
      expect(survey_version.temp_invitation_accepted_count[date_string]).to eq nil

      survey_version.increment_temp_invitation_accepted_count

      expect(survey_version.temp_invitation_accepted_count[date_string]).to eq "1"
    end

    context ".total_temp_visit_count" do
      it "sums up the temp visit counts for the previous days" do
        survey_version = FactoryGirl.create(:survey_version)
        Timecop.freeze(1.day.ago) do
          survey_version.increment_temp_visit_count
        end
        Timecop.freeze(Date.today) do
          survey_version.increment_temp_visit_count
        end
        expect(survey_version.temp_visit_count.length).to eq 2
        expect(survey_version.total_temp_visit_count).to eq 2
      end
    end

    context ".total_temp_invitation_count" do
      it "sums up the temp invitation counts for the previous days" do
        survey_version = FactoryGirl.create(:survey_version)
        Timecop.freeze(1.day.ago) do
          survey_version.increment_temp_invitation_count
        end
        Timecop.freeze(Date.today) do
          survey_version.increment_temp_invitation_count
        end
        expect(survey_version.total_temp_invitation_count).to eq 2
      end
    end

    context ".total_temp_invitation_accepted_count" do
      it "sums up the temp invitation accepted count" do
        survey_version = FactoryGirl.create(:survey_version)
        Timecop.freeze(1.day.ago) do
          survey_version.increment_temp_invitation_accepted_count
        end
        Timecop.freeze(Date.today) do
          survey_version.increment_temp_invitation_accepted_count
        end
        expect(survey_version.total_temp_invitation_accepted_count).to eq 2
      end

    end

    describe ".total_invitation_accepted_count" do
      context "when there are no survey_version_counts" do
        it "returns the temp invitation count" do
          survey_version = FactoryGirl.create(:survey_version)
          survey_version.increment_temp_invitation_accepted_count
          expect(survey_version.total_invitation_accepted_count).to eq 1
        end

        context "and there are no temp counts from today" do
          it "returns 0" do
            survey_version = FactoryGirl.create(:survey_version)
            expect(survey_version.total_invitation_accepted_count).to eq 0
          end
        end
      end

      context "when there are previous survey_version_counts" do
        it "returns the count from the survey_version_count object" do
          survey_version = FactoryGirl.create(:survey_version)
          Timecop.freeze(1.day.ago) do
            survey_version.increment_temp_invitation_accepted_count
          end
          survey_version.update_counts
          survey_version.reload
          expect(survey_version.survey_version_counts.count).to eq 1
          expect(survey_version.total_invitation_accepted_count).to eq 1
        end

        context "and there are temp counts from today" do

          it "adds the temp count for today to the stored counts" do
            survey_version = FactoryGirl.create(:survey_version)
            Timecop.freeze(1.day.ago) do
              survey_version.increment_temp_invitation_accepted_count
              expect(survey_version.temp_invitation_accepted_count.keys)
                .to include(date_string(Date.today))
            end
            survey_version.update_counts
            expect(survey_version.survey_version_counts.count).to eq 1
            survey_version.increment_temp_invitation_accepted_count
            survey_version.reload
            expect(survey_version.total_invitation_accepted_count).to eq 2
          end
        end
      end
    end
  end

  def date_string(date = Date.today)
    date.strftime("%Y-%m-%d")
  end
end
