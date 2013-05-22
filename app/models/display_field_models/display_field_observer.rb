# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Housekeeping Observer for the DisplayField model
class DisplayFieldObserver < ActiveRecord::Observer
  observe :display_field

  # On creation of a DisplayField, build associated DisplayFieldValues for each SurveyResponse;
  # this can be an expensive operation, so defer to delayed_job
  # 
  # @param [DisplayField] display_field the DisplayField to call back to
  def after_create(display_field)
    display_field.async(:"populate_default_values!")
  end

  # On destroy of a DisplayField, reorder the remaining DisplayFields in the SurveyVersion.
  # 
  # @param [DisplayField] display_field the DisplayField forcing the renumbering
  def after_destroy(display_field)
    display_fields = SurveyVersion.find(display_field.survey_version_id).display_fields.where("display_order > ?", display_field.display_order)
    display_fields.update_all("display_order = display_order - 1")
  end
end
