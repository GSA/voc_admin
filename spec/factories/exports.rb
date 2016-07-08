FactoryGirl.define do
  factory :export do
    document_file_name { "test_file.csv" }
    document_content_type { "text/csv" }
    document_file_size { 1024 }
  end
end
