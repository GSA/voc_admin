require "rails_helper"

RSpec.feature "User downloads CSV export" do
  scenario"they should see a 404 page when the link has expired" do
    login_user
    export = create_export created_at: 26.hours.ago
    expect { visit export.document.url }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def create_export created_at: Time.now
    Export.create!(
      document_file_name: "Expired Export",
      document_content_type: "text/csv",
      document_file_size: 1024,
      created_at: created_at,
      survey_version_id: 1
    )
  end
end
