# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Represents a single sent of answers to the questions contained within
# a SurveyVersion. Where a SurveyVersion contains DisplayFields representing
# the columns in the response (and custom fields), the SurveyResponse
# contains DisplayFieldValues for each of those DisplayFields. In addition,
# the SurveyResponse links to the RawResponses, which are the historical
# and unedited responses as entered by the survey taker.
class SurveyResponse < ActiveRecord::Base
  include ResqueAsyncRunner
  @queue = :voc_responses

  has_many :raw_responses, :dependent => :destroy
  has_many :display_field_values
  belongs_to :survey_version
  belongs_to :raw_submission

  validates :survey_version, :presence => true

  default_scope { where(:archived => false) }

  accepts_nested_attributes_for :raw_responses, :reject_if => :invalid_raw_response?
  accepts_nested_attributes_for :display_field_values

  after_create :queue_for_processing
  after_create :create_dfvs

  scope :search, (lambda do |search_text = ""|
    joins('INNER JOIN (select * from display_field_values) t1 on t1.survey_response_id = survey_responses.id')
    .where("t1.value LIKE ? ", "%#{search_text}%").select("DISTINCT survey_responses.*")
  end)

  scope :search_rr, (lambda do |qc_id, search_text = ""|
    joins(:raw_responses)
    .where(raw_responses: {question_content_id: qc_id})
    .where("raw_responses.answer LIKE ?", "%#{search_text}%")
  end)

  # perform a fairly ugly join to accomplish the Custom View ordering,
  # while still supporting the original functionality
  scope :order_by_display_field, (lambda do |column_id, order_dir|

    # if no column specified, sort by created date and fall back on ASC order
    if column_id.blank?
      self.order("survey_responses.created_at #{order_dir || 'ASC'}")
    else

      # columns and orders come in as separate arrays (or single values)
      # splat them to guarantee we're working with arrays for both
      columns = *column_id
      orders = *order_dir

      # zip them back together, e.g. [4, 2, 3], ['ASC', 'DESC', 'DESC']
      # becomes [[4, 'ASC'], [2, 'DESC'], [3, 'DESC']]
      # -- this also ensures that we're only creating as many pairs as the shortest list contains
      sorts = columns.zip(orders)

      # self is an ActiveRecord::Relation in this context
      relation = self

      # this is messy (re-joining the same table up to three times) but couldn't come up with
      # a more straightforward way to sort by the DisplayFieldValues for CustomViews
      sorts.each { |c, o|
        relation = relation.joins("INNER JOIN (SELECT value, survey_response_id FROM display_field_values WHERE display_field_id = #{c}) t#{c} ON survey_responses.id = t#{c}.survey_response_id")
      }

      # apply the order clause
      relation = relation.order(sorts.map {|c, o| "t#{c}.value #{o}" }.join(", "))
    end
  end)

  #used for alarm notifications
  scope :created_between, lambda {|start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date )}

  scope :processed, -> { where(:status_id => Status::DONE) }

  # kaminari setting
  paginates_per 50

  # Create a SurveyResponse from the RawResponse.  This is used by Resque to process the
  # survey responses asynchronously.
  #
  # @param [Hash] response the response parameter hash to process from the controller
  # @param [Integer] survey_version_id the id of the SurveyVersion
  def self.process_response(response, survey_version_id, submitted_at = Time.now)
    client_id = SecureRandom.hex(64)

    # Remove extraneous data from the response
    response.slice!('page_url', 'raw_responses_attributes', 'device')
    response['raw_responses_attributes'].try(:values).try(:each) do |rr|
      rr.slice!('question_content_id', 'answer')
      rr['question_content_id'] = rr['question_content_id'].to_i
    end

    survey_response = SurveyResponse.new({:client_id => client_id, :survey_version_id => survey_version_id}.merge(response))

    ## Work around for associating the child raw responses with the survey_response
    survey_response.raw_responses.each do |raw_response|
      raw_response.client_id = client_id
      raw_response.survey_response = survey_response
    end

    survey_response.created_at = submitted_at

    survey_response.save!

    survey_response.process_me 1
  end

  # Process all rules for the SurveyVersion and apply them to this SurveyResponse.
  # Passing no parameters will evaluate all Rules regardless of ExecutionTrigger.
  #
  # @param [Array<Integer>] trigger_id splat of ExecutionTrigger id parameters
  def process_me(*trigger_id)

    #if no triggers specified, do them all
    if trigger_id.size == 0
      trigger_id = ExecutionTrigger.all.map {|et| et.id}
    end

    begin
      ActiveRecord::Base.transaction do
        Rule.where(survey_version_id: self.survey_version_id).each do |rule|
          begin
            rule.apply_me(self)
            self.update_attributes(:status_id => Status::DONE, :last_processed => Time.now)
          rescue
            raise "Processing Failed - #{$!.to_s}"
          end
        end
      end
    rescue
      self.update_attributes(:status_id => Status::ERROR, :worker_name => "", :last_processed => Time.now)
      raise "Processing Failed - #{$!.to_s}"
    end

    # do record keeping (status is already set, so we need to remove worker name and new response record
    sql = ActiveRecord::Base.connection();
    sql.delete("delete from new_responses where survey_response_id = #{self.id}")
    self.update_attributes(:worker_name => "", :last_processed => Time.now)

    # Flatten the results and export to mongo.
    # Note: Both process_me and export_values_for_reporting may be better off being moved to
    # after_save callbacks to ensure they run in the correct order to avoid timing issues and
    # cleanup the code.
    export_values_for_reporting
  end

  # Mark the SurveyResponse as archived (soft deleted.)
  def archive
    self.archived = true
    reportable_survey_response = ReportableSurveyResponse.where(survey_response_id: id).first.try(:delete)
    self.save!
    resp = ReportableSurveyResponse.unscoped.where(survey_response_id: self.id).first
    if resp
      resp.archived = true
      resp.save!
    end  
  end

  def export_values_for_reporting
    resp = ReportableSurveyResponse.find_or_initialize_by(survey_response_id: self.id)

    resp.survey_id = self.survey_version.survey_id
    resp.survey_version_id = self.survey_version_id

    answers = {}
    self.display_field_values.each do |dfv|
      answers[dfv.display_field_id.to_s] = dfv.value
    end

    raw_answers = {}
    raw_responses.each do |rr|
      raw_answers[rr.question_content_id.to_s] = rr.answer
    end

    resp.answers = answers
    resp.raw_answers = raw_answers

    resp.created_at = self.created_at
    resp.page_url = self.page_url
    resp.device = self.device
    resp.archived = self.archived

    resp.save
  end

  private

  def queue_for_processing
    NewResponse.create(:survey_response_id => self.id) if self.id
  end

  # Ensure that there is a DisplayFieldValue ("cell") for every column in the SurveyResponse.
  def create_dfvs
    DisplayField.where(survey_version_id: self.survey_version_id).each do |df|
      dfv = DisplayFieldValue.find_or_create_by(survey_response_id: self.id, display_field_id: df.id)
      dfv.update_attributes(:value => df.default_value)
    end
  end

  # question content ids associated with this survey version
  def question_content_ids
    return @question_content_ids unless @question_content_ids.nil?
    @question_content_ids = survey_version.try(:questions).try(:map) do |q|
      if q.is_a?(MatrixQuestion) # get the ids of questins associated with MatrixQuestion
        q.choice_questions.map {|cq| cq.question_content.try(:id)}
      else
        q.question_content.try(:id)
      end
    end
    @question_content_ids ||= []
    @question_content_ids.flatten!
    @question_content_ids.reject! {|i| i.blank?}
    @question_content_ids
  end

  # raw response is invalid if blank or if the question_content_id isn't part of this survey version
  def invalid_raw_response?(attr)
    attr['answer'].blank? || !question_content_ids.detect {|i| i == attr['question_content_id']}
  end
end

# == Schema Information
#
# Table name: survey_responses
#
#  id                :integer          not null, primary key
#  client_id         :string(255)
#  survey_version_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  status_id         :integer          default(1), not null
#  last_processed    :datetime
#  worker_name       :string(255)
#  page_url          :text
#  archived          :boolean          default(FALSE)
#  device            :string(255)      default("Desktop")
#
