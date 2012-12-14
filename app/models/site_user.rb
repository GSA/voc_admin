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
#  id         :integer(4)      not null, primary key
#  site_id    :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
