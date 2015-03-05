# == Schema Information
#
# Table name: saved_searches
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  survey_version_id :integer
#  search_params     :text
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe SavedSearch do
  pending "add some examples to (or delete) #{__FILE__}"
end
