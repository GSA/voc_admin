# Used for rules associated with a survey response's page url
class PageUrl
  include Singleton

  def self.find(*args)
    PageUrl.instance
  end

  def id
    0
  end

  def get_display_field_header
    "Page URL"
  end

  def find_my_clone_for(clone_survey_version)
    PageUrl.instance
  end

  def check_condition(survey_response, conditional_id, test_value)
    ConditionTester.test(conditional_id, survey_response.page_url, test_value)
  end
end

