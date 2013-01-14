class DisplayFieldObserver < ActiveRecord::Observer
  observe :display_field

  def after_create(display_field)
    display_field.delay.populate_default_values!
  end

  def after_destroy(display_field)
    display_fields = SurveyVersion.find(display_field.survey_version_id).display_fields.order(:display_order).where("display_order > ?", display_field.display_order)
    display_fields.update_all("display_order = display_order - 1")
  end
end
