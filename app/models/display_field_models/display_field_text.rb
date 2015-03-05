# == Schema Information
#
# Table name: display_fields
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  type              :string(255)      not null
#  required          :boolean          default(FALSE)
#  searchable        :boolean          default(FALSE)
#  default_value     :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  display_order     :integer          not null
#  survey_version_id :integer
#  clone_of_id       :integer
#  choices           :string(255)
#  editable          :boolean          default(TRUE)
#

# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# This class is not yet implemented.
class DisplayFieldText < DisplayField
end

# == Schema Information
#
# Table name: display_fields
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)     not null
#  type              :string(255)     not null
#  required          :boolean(1)      default(FALSE)
#  searchable        :boolean(1)      default(FALSE)
#  default_value     :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  display_order     :integer(4)      not null
#  survey_version_id :integer(4)
#  clone_of_id       :integer(4)
#  choices           :string(255)
#  editable          :boolean(1)      default(TRUE)
