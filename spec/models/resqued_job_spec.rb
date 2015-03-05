# == Schema Information
#
# Table name: resqued_jobs
#
#  id            :integer          not null, primary key
#  class_name    :string(255)
#  job_arguments :text(2147483647)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe ResquedJob do
  pending "add some examples to (or delete) #{__FILE__}"
end
