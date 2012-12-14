class SurveyResponse < ActiveRecord::Base
  has_many :raw_responses, :dependent => :destroy
  # has_many :question_contents
  has_many :display_field_values
  belongs_to :survey_version

  validates :survey_version, :presence => true

  default_scope where(:archived => false)

  accepts_nested_attributes_for :raw_responses, :reject_if => lambda {|attr| attr['answer'].blank?}
  accepts_nested_attributes_for :display_field_values

  after_create :queue_for_processing

  scope :search, (lambda do |search_text = ""|
    joins('INNER JOIN (select * from display_field_values) t1 on t1.survey_response_id = survey_responses.id')
    .where("t1.value LIKE ? ", "%#{search_text}%").select("DISTINCT survey_responses.*")#.group("survey_responses.id") # this group clause has to be added so that rails will handle the count correctly with the distinct select
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

      relation = self

      # this is messy (re-joining the same table up to three times) but couldn't come up with
      # a more straightforward way to sort by the Display Field Values for Custom Views
      sorts.each do |c, o|
        relation = relation.joins("INNER JOIN (SELECT value, survey_response_id FROM display_field_values WHERE display_field_id = #{c}) t#{c} ON survey_responses.id = t#{c}.survey_response_id")
      end

      # apply the order clause
      relation = relation.order(sorts.map {|c, o| "t#{c}.value #{o}" }.join(", "))
    end
  end)

  scope :processed, where(:status_id => Status::DONE)

  paginates_per 10

  # Create a survey response from the raw_response.  This is used by DelayedJob to process the
  # survey responses asynchronouly
  def self.process_response response, survey_version_id
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

  # Process all rules for the survey version and apply them to the SurveyResponse
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
            self.update_attributes(:status_id=>Status::DONE, :last_processed=>Time.now)
          rescue
            # puts "Error processing survey response #{self.id} - #{$!.to_s}"
            raise "Processing Failed - #{$!.to_s}"
          end
        end
      end
    rescue
      self.update_attributes(:status_id => Status::ERROR, :worker_name=> "", :last_processed=>Time.now)
      raise "Processing Failed - #{$!.to_s}"
    end
    #do record keeping (status is already set, so we need to remove worker name and new response record
    sql = ActiveRecord::Base.connection();
    sql.delete("delete from new_responses where survey_response_id = #{self.id}")
    self.update_attributes(:worker_name=> "", :last_processed=>Time.now)
  end

  def self.get_next_response(worker_name, mode, *date)
      ActiveRecord::Base.transaction do
        #get next response (locking so we can stop other workers from grabbing it)
        response = SurveyResponse.find_by_worker_name(worker_name, :lock => true)
        if mode =="new"
          nr_id = NewResponse.next_response.first.try(:survey_response_id)
          return(nil) unless nr_id
          response ||= SurveyResponse.find(nr_id, :lock => true)
        elsif mode == "nightly"
          response ||= SurveyResponse.where("last_processed < ? ", date[0]).first
          return(nil) unless response
        end
        #set it's status and worker
        response.update_attributes(:status_id=>Status::PROCESSING, :worker_name=>worker_name)
        response #return the reponse
      end
    end

  def queue_for_processing
    NewResponse.create(:survey_response_id => self.id)if self.id
  end

  # Mark the SurveyResponse as archived
  def archive
    self.archived = true
    self.save!
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
#

