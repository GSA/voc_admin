class SurveyVersionReporter
  include Mongoid::Document

  field :s_id, type: Integer    # Survey id
  field :sv_id, type: Integer   # Survey Version id
  field :counts_updated_at, type: DateTime
  field :questions_asked, type: Integer
  field :questions_skipped, type: Integer

  embeds_many :survey_version_days
  embeds_many :text_question_reporters
  embeds_many :choice_question_reporters

  index "sv_id" => 1

  def self.update_reporters
    survey_versions = SurveyVersion.locked
    survey_version_count = survey_versions.count

    survey_versions.each_with_index do |survey_version, index|
      Rails.logger.info "Now processing SV #{survey_version.id}, #{index} of #{survey_version_count}."
      SurveyVersionReporter.find_or_create_reporter(survey_version.id).update_reporter!
      Rails.logger.info "Finished processing SV #{survey_version.id}."
    end
  end

  def self.find_or_create_reporter(survey_version_id)
    survey_version_reporter = SurveyVersionReporter.where(sv_id: survey_version_id).first
    return survey_version_reporter if survey_version_reporter
    survey_version = SurveyVersion.where(id: survey_version_id).first
    return nil unless survey_version
    SurveyVersionReporter.create(sv_id: survey_version.id, s_id: survey_version.survey_id)
  end

  def self.find_choice_question_reporter(choice_question)
    svr = SurveyVersionReporter.where(sv_id: choice_question.survey_version.id).first
    return unless svr
    svr.choice_question_reporters.where(q_id: choice_question.id).first
  end

  def self.find_text_question_reporter(text_question)
    svr = SurveyVersionReporter.where(sv_id: text_question.survey_version.id).first
    return unless svr
    svr.text_question_reporters.where(q_id: text_question.id).first
  end

  def find_or_create_choice_question_reporter(choice_question)
    choice_question_reporter = choice_question_reporters.where(q_id: choice_question.id).first
    return choice_question_reporter if choice_question_reporter
    choice_question_reporters.create(q_id: choice_question.id,
        qc_id: choice_question.question_content.id,
        se_id: choice_question.survey_element.id,
        question_text: choice_question.question_content.statement)
  end

  def find_or_create_text_question_reporter(text_question)
    text_question_reporter = text_question_reporters.where(q_id: text_question.id).first
    return text_question_reporter if text_question_reporter
    text_question_reporters.create(q_id: text_question.id,
        qc_id: text_question.question_content.id,
        se_id: text_question.survey_element.id,
        question_text: text_question.question_content.statement)
  end

  def survey_version
    @survey_version ||= SurveyVersion.find(sv_id)
  end

  def update_reporter!
    update_choice_question_reporters
    update_text_question_reporters
    update_questions_skipped_and_asked
    self.counts_updated_at = Time.now
    save
    survey_version.mark_reports_clean!
  end

  def question_reporters
    choice_question_reporters + text_question_reporters
  end

  private

  def update_choice_question_reporters
    Rails.logger.info "  Choice questions:"
    survey_version.choice_questions.each do |choice_question|
      Rails.logger.info "    Importing CQID #{choice_question.id}..."
      begin
        find_or_create_choice_question_reporter(choice_question).update_reporter!
      rescue Exception => e
        Rails.logger.error "ERROR: Failed import for ChoiceQuestion #{choice_question.id};\n  Message: #{$!.to_s}\n  Backtrace: #{e.backtrace}"
      end
    end
  end

  def update_text_question_reporters
    Rails.logger.info "  Text questions:"
    survey_version.text_questions.each do |text_question|
      Rails.logger.info "    Importing TQID #{text_question.id}..."

      begin
        find_or_create_text_question_reporter(text_question).update_reporter!
      rescue Exception => e
        Rails.logger.error "ERROR: Failed import for TextQuestion #{text_question.id};\n  Message: #{$!.to_s}\n  Backtrace: #{e.backtrace}"
      end
    end
  end

  # updates the number of questions asked and skipped in survey responses
  def update_questions_skipped_and_asked
    responses = survey_version.survey_responses
    if counts_updated_at.present?
      d = counts_updated_at.in_time_zone("Eastern Time (US & Canada)") - 2.days
      responses = responses.where("created_at > ?", d.to_date)
    end
    return if responses.empty?
    page_hash = survey_version.page_hash
    first_page = page_hash.values.detect {|page| page[:page_number] == 1}.try(:[], :page_id)

    skips_hash = new_skips_hash
    responses.each do |sr|
      date = sr.created_at.in_time_zone("Eastern Time (US & Canada)").to_date
      raw_responses = Hash[sr.raw_responses.map {|rr| [rr.question_content_id, rr]}]
      next_page = first_page
      while next_page do
        page = page_hash[next_page]
        next_page = page[:next_page_id]
        page[:questions].each do |question|
          rr = raw_responses[question[:qc_id]]
          question_skips_hash = case question[:questionable_type]
          when "ChoiceQuestion" then skips_hash[:choice_days]
          when "TextQuestion" then skips_hash[:text_days]
          end
          skips_hash[:days][date][:total] += 1
          question_skips_hash[question[:questionable_id]][date][:total] += 1 if question_skips_hash

          if rr.present?
            if question[:flow_control] && question[:flow_map][rr.answer].present?
              next_page = question[:flow_map][rr.answer]
            end
          else
            skips_hash[:days][date][:skip] += 1
            question_skips_hash[question[:questionable_id]][date][:skip] += 1 if question_skips_hash
          end
        end
      end
    end
    record_questions_skipped_and_asked(skips_hash)
  end

  # saves the skips from update_questions_skipped_and_asked
  def record_questions_skipped_and_asked(skips_hash)
    skips_hash[:days].each do |date, hash|
      day = survey_version_days.find_or_create_by(date: date)
      day.questions_asked = hash[:total]
      day.questions_skipped = hash[:skip]
    end
    self.questions_asked = survey_version_days.pluck(:questions_asked).compact.sum
    self.questions_skipped = survey_version_days.pluck(:questions_skipped).compact.sum
    save
    skips_hash[:choice_days].each do |id, days|
      cqr = choice_question_reporters.where(q_id: id).first
      next unless cqr
      days.each do |date, hash|
        day = cqr.choice_question_days.find_or_create_by(date: date)
        day.questions_asked = hash[:total]
        day.questions_skipped = hash[:skip]
      end
      cqr.questions_asked = cqr.choice_question_days.pluck(:questions_asked).compact.sum
      cqr.questions_skipped = cqr.choice_question_days.pluck(:questions_skipped).compact.sum
      cqr.save
    end
    skips_hash[:text_days].each do |id, days|
      tqr = text_question_reporters.where(q_id: id).first
      next unless tqr
      days.each do |date, hash|
        day = tqr.text_question_days.find_or_create_by(date: date)
        day.questions_asked = hash[:total]
        day.questions_skipped = hash[:skip]
      end
      tqr.questions_asked = tqr.text_question_days.pluck(:questions_asked).compact.sum
      tqr.questions_skipped = tqr.text_question_days.pluck(:questions_skipped).compact.sum
      tqr.save
    end
  end

  # generates a hash that looks like
  # {
  #   :days => {
  #     entered_date => { :skip => 0, :total => 0 }
  #   },
  #   :choice_days => {
  #     entered_id => {
  #       entered_date => { :skip => 0, :total => 0 }
  #     }
  #   }
  #   :text_days => {
  #     entered_id => {
  #       entered_date => { :skip => 0, :total => 0 }
  #     }
  #   }
  # }
  def new_skips_hash
    hash = {days: Hash.new {|hash, key| hash[key] = {skip: 0, total: 0}}}
    hash[:choice_days] = Hash.new {|hash, key| hash[key] = Hash.new {|h, k| h[k] = {skip: 0, total: 0}}}
    hash[:text_days] = Hash.new {|hash, key| hash[key] = Hash.new {|h ,k| h[k] = {skip: 0, total: 0}}}
    hash
  end
end
