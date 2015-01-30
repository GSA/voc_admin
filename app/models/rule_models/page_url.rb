# Used for rules criteria associated with a survey response's page url.
# Since it's done on the survey response, we can't set a real id for criterion source.
# We need some sort of id because of polymorphism.
# Use a Singleton that's pretending to be an AR model instead
class PageUrl
  include Singleton
  ID = 0
  DISPLAY_FIELD_HEADER = "Page URL"

  # Fake AR method so the polymorphism works.
  def self.find(*args)
    PageUrl.instance
  end

  # Use an id of 0 because it doesn't really matter. Needed for polymorphism and rules cloning.
  def id
    ID
  end

  # This gets displayed on the show page when a page url is a criterion.
  def get_display_field_header
    DISPLAY_FIELD_HEADER
  end

  # Needed for cloning a rule.
  def find_my_clone_for(clone_survey_version)
    PageUrl.instance
  end

  # Check whether the survey response page url fits the given condition.
  def check_condition(survey_response, conditional_id, test_value)
    ConditionTester.test(conditional_id, survey_response.page_url, test_value)
  end
end

