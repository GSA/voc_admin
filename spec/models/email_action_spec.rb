require 'spec_helper'

describe EmailAction do
  pending "add some examples to (or delete) #{__FILE__}"
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
#

