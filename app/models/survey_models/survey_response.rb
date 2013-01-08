# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Represents a single sent of answers to the questions contained within
# a SurveyVersion. Where a SurveyVersion contains DisplayFields representing
# the columns in the response (and custom fields), the SurveyResponse
# contains DisplayFieldValues for each of those DisplayFields. In addition,
# the SurveyResponse links to the RawResponses, which are the historical
# and unedited responses as entered by the survey taker.
class SurveyResponse < ActiveRecord::Base

  has_many :raw_responses, :dependent => :destroy
  has_many :display_field_values
  belongs_to :survey_version

  validates :survey_version, :presence => true

  default_scope where(:archived => false)

  accepts_nested_attributes_for :raw_responses, :reject_if => lambda {|attr| attr['answer'].blank?}
  accepts_nested_attributes_for :display_field_values

  after_create :queue_for_processing
  after_create :create_dfvs

  scope :search, (lambda do |search_text = ""|
    joins('INNER JOIN (select * from display_field_values) t1 on t1.survey_response_id = survey_responses.id')
    .where("t1.value LIKE ? ", "%#{search_text}%").select("DISTINCT survey_responses.*")
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

  scope :processed, where(:status_id => Status::DONE)

  # kaminari setting
  paginates_per 10

  # Create a SurveyResponse from the RawResponse.  This is used by Delayed::Job to process the
  # survey responses asynchronously.
  # 
  # @param [Hash] response the response parameter hash to process from the controller
  # @param [Integer] survey_version_id the id of the SurveyVersion
  def self.process_response(response, survey_version_id)
    client_id = SecureRandom.hex(64)

    survey_response = SurveyResponse.new ({:client_id => client_id, :survey_version_id => survey_version_id}.merge(response))

    ## Work around for associating the child raw responses with the survey_response
    survey_response.raw_responses.each do |raw_response|
      raw_response.client_id = client_id
      raw_response.survey_response = survey_response
    end

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
        Rule.find_all_by_survey_version_id(self.survey_version_id).each do |rule|
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
  end

  # Used by the response_parser rake task to select SurveyResponses in sequence for
  # processing of nightly Rules.
  # 
  # @param [String] worker_name the worker thread name
  # @param [Date] date last run date, i.e. now
  # @return [nil, SurveyResponse] the next SurveyResponse to process, if applicable
  def self.get_next_response(worker_name, mode, *date)
      ActiveRecord::Base.transaction do
        
        # get next response (locking so we can stop other workers from grabbing it)
        response = SurveyResponse.find_by_worker_name(worker_name, :lock => true)
        
        if mode =="new"
          nr_id = NewResponse.next_response.first.try(:survey_response_id)
          return(nil) unless nr_id
          response ||= SurveyResponse.find(nr_id, :lock => true)
        elsif mode == "nightly"
          response ||= SurveyResponse.where("last_processed < ? ", date[0]).first
          return(nil) unless response
        end
        
        # set its status and worker
        response.update_attributes(:status_id => Status::PROCESSING, :worker_name => worker_name)
        
        # return the reponse
        response
      end
    end

  # Mark the SurveyResponse as archived (soft deleted.)
  def archive
    self.archived = true
    self.save!
  end

  private

  def queue_for_processing
    NewResponse.create(:survey_response_id => self.id) if self.id
  end

  # Ensure that there is a DisplayFieldValue ("cell") for every column in the SurveyResponse.
  def create_dfvs
    DisplayField.find_all_by_survey_version_id(self.survey_version_id).each do |df|
      dfv = DisplayFieldValue.find_or_create_by_survey_response_id_and_display_field_id(self.id, df.id)
      dfv.update_attributes(:value => df.default_value)
    end
  end
end

# == Schema Information
#
# Table name: survey_responses
#
#  id                :integer(4)      not null, primary key
#  client_id         :string(255)
#  survey_version_id :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  status_id         :integer(4)      default(1), not null
#  last_processed    :datetime
#  worker_name       :string(255)
#  page_url          :text
#  archived          :boolean(1)      default(FALSE)
