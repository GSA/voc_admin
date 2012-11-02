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

  # == Schema Information
  #
  # Table name: survey_versions
  #
  #  id             :integer(4)      not null, primary key
  #  survey_id      :integer(4)      not null
  #  major          :integer(4)
  #  minor          :integer(4)
  #  published      :boolean(1)      default(FALSE)
  #  locked         :boolean(1)      default(FALSE)
  #  archived       :boolean(1)      default(FALSE)
  #  notes          :text
  #  created_at     :datetime
  #  updated_at     :datetime
  #  thank_you_page :text
  factory :survey_version do
    sequence(:major)
    sequence(:minor)
    survey
  end

  # == Schema Information
  #
  # Table name: custom_views
  #
  #  id                :integer(4)      not null, primary key
  #  survey_version_id :integer(4)
  #  name              :string(255)
  #  order_clause      :text
  #  default           :boolean(1)
  #  created_at        :datetime
  #  updated_at        :datetime
  factory :custom_view do
    sequence(:name)       {|n| "Rspec Test Survey Version #{n}"}
    default               false
    survey_version
  end

  # == Schema Information
  #
  # Table name: execution_triggers
  #
  #  id         :integer(4)      not null, primary key
  #  name       :string(255)     not null
  #  created_at :datetime
  #  updated_at :datetime
  factory :execution_trigger do
    sequence(:name)       {|n| "trigger #{n}"}
  end
end