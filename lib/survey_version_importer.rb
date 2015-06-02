class SurveyVersionImporter
  attr_reader :survey, :export_file, :source_sv_id

  def initialize(survey, export_file, source_sv_id = nil)
    @survey = survey
    @export_file = export_file
    @source_sv_id = source_sv_id
  end

  def data_hash
    @data_hash ||= JSON.parse(export_file.read)
  end

  def next_major_version_number
    survey.survey_versions.maximum(:major).to_i + 1
  end

  def create_survey_version
    @survey_version = survey.survey_versions.create(
      major: next_major_version_number,
      minor: 0,
      published: false,
      locked: false,
      archived: false,
      notes: 'Created via Import Process',
      created_by_id: source_sv_id
    )
  end

  def create_page(page_number)
    survey_version.pages.create( :page_number => page_number )
  end

  def survey_version
    @survey_version ||= create_survey_version
  end

  def choice_answer_page_mappings
    @choice_answer_page_mappings ||= {}
  end

  def import
    data_hash["pages"].each do |page|
      new_page = create_page page["page_number"]

      page["survey_elements"].each do |element|

        if element["assetable_type"] == "ChoiceQuestion"
          new_cq = survey_version.choice_questions.build(
            answer_type: element["answer_type"],
            auto_next_page: element["auto_next_page"]
          )

          new_cq.build_survey_element(
            page: new_page,
            survey_version: survey_version
          )

          new_cq.build_question_content(
            statement: element["statement"],
            flow_control: element["flow_control"]
          )

          element["choice_answers"].each do |answer|
            choice_answer = new_cq.choice_answers.build(answer: answer["answer"])
            if answer["next_page"].present?
              choice_answer_page_mappings[choice_answer] = answer["next_page"]
            end
          end

          new_cq.save!
        end

        if element["assetable_type"] == "TextQuestion"
          new_tq = survey_version.text_questions.build(answer_type: element["answer_type"], answer_size: element["answer_size"])

          new_tq.build_survey_element.tap do |se|
            se.page = new_page
            se.survey_version = survey_version
          end
          new_tq.build_question_content.tap do |tc|
            tc.statement = element["statement"]
          end
          new_tq.save!
          s_asset = new_tq.survey_element.id
        end

        if element["assetable_type"] == "MatrixQuestion"
          new_mq = survey_version.matrix_questions.new(survey_version_id: survey_version.id)
          # new_mq = survey_version.matrix_questions.build
          new_mq.build_survey_element.tap do |se|
            se.page = new_page
            se.survey_version = survey_version
          end
          new_mq.build_question_content.tap do |mc|
            mc.statement = element["statement"]
            mc.flow_control = element["flow_control"]
          end
          element["choice_questions"].each do |cq|
            new_cq = new_mq.choice_questions.build(answer_type: cq["answer_type"], auto_next_page: cq["auto_next_page"])
            new_cq.build_question_content.tap do |qc|
              qc.statement = cq["statement"]
              qc.flow_control = element["flow_control"]
            end
            cq["choice_answers"].each do |answer|
             new_cq.choice_answers.build(answer: answer["answer"])
            end
          end

          new_mq.save!

          s_asset = new_mq.survey_element.id
        end

        if element["assetable_type"] == "Asset"
          new_asset = survey_version.assets.build(
            snippet: element["snippet"],
            survey_element_attributes: {
              page: new_page,
              survey_version: survey_version
            }
          )
          new_asset.save!
          s_asset = new_asset.survey_element.id
        end
      end
    end

    data_hash["pages"].each do |page_data|
      next if page_data["next_page"].nil?
      if page_data["page_number"].to_i != (page_data["next_page"].to_i - 1)
        page = survey_version.pages.find_by_page_number(page_data["page_number"].to_i)
        next_page_id = survey_version.pages.find_by_page_number(page_data["next_page"].to_i).id
        page.update_attribute(:next_page_id, next_page_id)
      end
    end

    choice_answer_page_mappings.each_pair do |choice_answer, page_number|
      next_page_id = survey_version.pages.find_by_page_number(page_number).id
      choice_answer.update_attribute(:next_page_id, next_page_id)
    end
  end

  def self.import(survey, export_file, source_sv_id = nil)
    new(survey, export_file, source_sv_id).import
  end
end
