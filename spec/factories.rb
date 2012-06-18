FactoryGirl.define do
  # == Schema Information
  #
  # Table name: sites
  #
  #  id          :integer(4)      not null, primary key
  #  name        :string(255)
  #  url         :string(255)
  #  description :text
  #  created_at  :datetime
  #  updated_at  :datetime
  factory :site do
    sequence(:name)       {|n| "Rspec Test Site #{n}"}
    sequence(:url)        {|n| "http://www.example#{n}.com"}
    description           "Rspec test site created using Factory Girl"
  end

  # == Schema Information
  # Schema version: 20110408150334
  #
  # Table name: survey_types
  #
  #  id         :integer(4)      not null, primary key
  #  name       :string(255)
  #  created_at :datetime
  #  updated_at :datetime
  factory :survey_type do
    sequence(:name)       {|n| "Survey Type #{n}"}
  end

  # == Schema Information
  #
  # Table name: surveys
  #
  #  id             :integer(4)      not null, primary key
  #  name           :string(255)
  #  description    :text
  #  survey_type_id :integer(4)
  #  created_at     :datetime
  #  updated_at     :datetime
  #  archived       :boolean(1)      default(FALSE)
  #  site_id        :integer(4)
  factory :survey do
    sequence(:name)       {|n| "Rspec Test Survey #{n}"}
    description           "Rspec test survey created by Factory Girl"
    survey_type
    site
  end
end