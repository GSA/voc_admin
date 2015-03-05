# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Join table between Sites and the Users who have access to them.
class SiteUser < ActiveRecord::Base
  attr_accessible :site_id, :user_id

  belongs_to :user
  belongs_to :site
end

# == Schema Information
#
# Table name: site_users
#
#  id         :integer          not null, primary key
#  site_id    :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

