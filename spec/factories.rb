FactoryGirl.define do
  # == Schema Information
  #
  # Table name: users
  #
  #  id                :integer(4)      not null, primary key
  #  f_name            :string(255)     not null
  #  l_name            :string(255)     not null
  #  locked            :boolean(1)
  #  email             :string(255)     not null
  #  crypted_password  :string(255)     not null
  #  password_salt     :string(255)     not null
  #  persistence_token :string(255)     not null
  #  created_at        :datetime
  #  updated_at        :datetime
  #  role_id           :integer(4)
  factory :user do
    f_name                  "Test"
    sequence(:l_name)       { |n| "User-#{n}"}
    email                   { "#{f_name}.#{l_name}@example.com" }
    password                "password"
    password_confirmation   "password"

    trait :admin do
      role                  { Role::ADMIN }
    end

    trait :user do
      role nil
    end
  end

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
    sequence(:name)           {|n| "Rspec Test Site #{n}"}
    sequence(:url)            {|n| "http://www.example#{n}.com"}
    description               "Rspec test site created using Factory Girl"
  end

  # == Schema Information
  #
  # Table name: roles
  #
  #  id         :integer(4)      not null, primary key
  #  name       :string(255)
  #  created_at :datetime
  #  updated_at :datetime
  factory :role do
    sequence(:name)           {|n| "Rspec Test Role #{n}"}
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
    sequence(:name)           {|n| "Survey Type #{n}"}
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
    sequence(:name)           {|n| "Rspec Test Survey #{n}"}
    description               "Rspec test survey created by Factory Girl"
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
  # Table name: survey_elements
  #
  #  id                :integer(4)      not null, primary key
  #  page_id           :integer(4)
  #  element_order     :integer(4)
  #  assetable_id      :integer(4)
  #  assetable_type    :string(255)
  #  created_at        :datetime
  #  updated_at        :datetime
  #  survey_version_id :integer(4)
  factory :survey_element do

  end

  # == Schema Information
  #
  # Table name: assets
  #
  #  id         :integer(4)      not null, primary key
  #  snippet    :text
  #  created_at :datetime
  #  updated_at :datetime
  factory :asset do
    sequence(:snippet)        {|n| "Rspec Test Asset #{n}"}
    survey_element
  end

  # == Schema Information
  #
  # Table name: question_contents
  #
  #  id                :integer(4)      not null, primary key
  #  statement         :string(255)
  #  questionable_type :string(255)
  #  questionable_id   :integer(4)
  #  flow_control      :boolean(1)
  #  required          :boolean(1)      default(FALSE)
  #  created_at        :datetime
  #  updated_at        :datetime
  factory :choice_question do
    sequence(:statement)      {|n| "Rspec Test Asset #{n}"}
    questionable_type         "ChoiceQuestion"
    survey_element
    question_content
  end

  # == Schema Information
  #
  # Table name: survey_responses
  #
  #  id                :integer(4)      not null, primary key
  #  client_id         :string(255)
  #  survey_version_id :integer(4)
  #  created_at        :datetime
  #  updated_at        :datetime
  #  status_id         :integer(4)      default(1), not null
  #  last_processed    :datetime
  #  worker_name       :string(255)
  #  page_url          :text
  #  archived          :boolean(1)      default(FALSE)
  factory :survey_response do
    survey_version
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
    sequence(:name)           {|n| "Rspec Test Survey Version #{n}"}
    default                   false
    survey_version
  end

  # == Schema Information
  #
  # Table name: email_actions
  #
  #  id          :integer(4)      not null, primary key
  #  emails      :string(255)
  #  subject     :string(255)
  #  body        :text
  #  rule_id     :integer(4)
  #  clone_of_id :integer(4)
  #  created_at  :datetime
  #  updated_at  :datetime
  factory :email_action do
    sequence(:emails)         {|n| "address#{n}@domain.local"}
    sequence(:subject)        {|n| "Rspec Test Email Action #{n}"}
    sequence(:body)           {|n| "Rspec Test Email Action Message Body #{n}"}
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
    sequence(:name)           {|n| "trigger #{n}"}
  end

  # == Schema Information
  #
  # Table name: exports
  #
  #  id                    :integer(4)      not null, primary key
  #  access_token          :string(255)
  #  created_at            :datetime
  #  updated_at            :datetime
  #  document_file_name    :string(255)
  #  document_content_type :string(255)
  #  document_file_size    :integer(4)
  #  document_updated_at   :datetime
  factory :export do
    #sequence(:access_token)   {|n| n}
    document                  File.open(File.join(Rails.root, 'spec', 'fixtures', 'Null.png'), 'r')
  end
end