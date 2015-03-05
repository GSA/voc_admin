# == Schema Information
#
# Table name: reports
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  survey_version_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  start_date        :date
#  end_date          :date
#  limit_answers     :boolean          default(FALSE)
#

require 'spec_helper'

describe Report do
  pending "add some examples to (or delete) #{__FILE__}"
end
