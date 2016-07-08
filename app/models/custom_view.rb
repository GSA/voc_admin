# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Custom Views are used to render survey responses with a given set of DisplayFields;
# allows ordering on up to three distinct DisplayFields (with sort directions).
# There can be a maximum of one "default" CustomView defined across a SurveyVersion,
# and if a default CustomView exists, it is rendered upon visiting View Responses.
class CustomView < ActiveRecord::Base
  attr_accessible :name, :default, :survey_version_id, :ordered_display_fields

  belongs_to :survey_version

  has_many :display_field_custom_views, :dependent => :destroy
  has_many :display_fields, -> { order("display_field_custom_views.display_order") },
    through: :display_field_custom_views

  validates :name, presence: true, uniqueness: { scope: :survey_version_id }, length: { maximum: 255 }
  validates :default, uniqueness: { scope: :survey_version_id }, :if => :default
  validates :survey_version, presence: true

  before_validation :update_default_fields

  # Captures the parameters necessary to display and/or order the SurveyResponses in a CustomView;
  # separate strings come in for 1.) the selected DisplayFields to present in SurveyResponses#index and
  # 2.) up to three DisplayFields (including direction) to sort the responses by.
  # Called during CustomView#create or CustomView#update.
  #
  # @param [Hash] params a Hash containing two strings: DisplayField ids in display order, and sort directives
  def ordered_display_fields=(params)

    # separate the hash and split the arrays by delimiters.
    #
    # selected DisplayField columns are a simple comma-delimited list.
    #
    # sort orders come in "id1:asc,id2:desc,id3:asc" format.  Since they're pairs,
    # we can split the whole string by comma and colon and hash it
    # (note: the colon may seem superfluous but it simplifies the JS a great deal)
    selected, sorts = params['selected'].split(','), params['sorts'].split(/,|:/)

    # prepare a hash to store the parameters for the DisplayFieldCustomView join objects
    attribs = {}

    # for each selected DisplayField, set display order, link back to the Custom View,
    # and reference the actual DisplayField
    selected.each_with_index do |df_id, index|
      attribs[df_id] = {
        display_order: index,
        custom_view: self,
        display_field_id: df_id
      }
    end

    # original ordering string: "id1:asc,id2:desc,id3:asc"
    # split array: [ id1, "asc", id2, "desc", id3, "asc" ]
    # hashed collection for iteration ease: [ id1: "asc", id2: "desc", id3: "asc" ]
    sorts = Hash[*sorts]

    # for any/all sort orders, update the selected DisplayField attributes to include
    # desired sort order and sort direction
    sorts.each_with_index do |(df_id, dir), index|
      attribs[df_id][:sort_order] = index
      attribs[df_id][:sort_direction] = dir
    end

    # drop and recreate the join mappings on create or update
    self.display_field_custom_views = attribs.values.map {|attr| DisplayFieldCustomView.new attr }
  end

  # Determines how the selected display fields are presented in the Custom View form's multiselect box.
  #
  # @return [Array<DisplayField>] Array containing joined DisplayFields in display order
  def ordered_display_fields
    self.display_fields
  end

  # Determines which display fields are selected on the Custom View form (and their sort orders.)
  #
  # @return [Array<DisplayFieldCustomView>] Array of DisplayFieldCustomView objects with sort information
  def sorted_display_field_custom_views
    self.display_field_custom_views.where("sort_order IS NOT NULL").order(:sort_order)
  end

  private
  # If setting a custom view to be the default, set all others' default false.
  def update_default_fields
    self.survey_version.custom_views.where(:default => true).update_all(:default => false) if self.default
  end
end

# == Schema Information
#
# Table name: custom_views
#
#  id                :integer          not null, primary key
#  survey_version_id :integer
#  name              :string(255)
#  default           :boolean
#  created_at        :datetime
#  updated_at        :datetime
#

