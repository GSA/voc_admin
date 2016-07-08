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

  def create_asset(asset_data, page)
    survey_version.assets.build(
      snippet: asset_data["snippet"],
      survey_element_attributes: {
        page: page,
        survey_version: survey_version
      }
    ).save!
  end

  def create_choice_question(choice_question_data, page)
    new_cq = survey_version.choice_questions.build(
      answer_type: choice_question_data["answer_type"],
      auto_next_page: choice_question_data["auto_next_page"],
      answer_placement: choice_question_data["answer_placement"],
      display_results: choice_question_data["display_results"],
      survey_element_attributes: {
        page: page,
        survey_version: survey_version
      },
      question_content_attributes: {
        statement: choice_question_data["statement"],
        flow_control: choice_question_data["flow_control"],
        required: choice_question_data["required"]
      }
    )

    choice_question_data["choice_answers"].each do |answer|
      choice_answer = new_cq.choice_answers.build(answer: answer["answer"])
      if answer["next_page"].present?
        choice_answer_page_mappings[choice_answer] = answer["next_page"]
      end
    end

    new_cq.save!
  end

  def create_matrix_question(matrix_question_data, page)
    new_mq = survey_version.matrix_questions.new(
      survey_version_id: survey_version.id,
      survey_element_attributes: {
        page: page,
        survey_version: survey_version
      },
      question_content_attributes: {
        statement: matrix_question_data["statement"],
        flow_control: matrix_question_data["flow_control"],
        required: matrix_question_data["required"]
      }
    )

    matrix_question_data["choice_questions"].each do |cq|
      new_cq = new_mq.choice_questions.build(
        answer_type: cq["answer_type"],
        auto_next_page: cq["auto_next_page"],
        question_content_attributes: {
          statement: cq["statement"],
          flow_control: cq["flow_control"],
          required: cq["required"]
        }
      )
      cq["choice_answers"].each do |answer|
       new_cq.choice_answers.build(answer: answer["answer"])
      end
    end

    new_mq.save!
  end

  def create_survey_version
    @survey_version = survey.survey_versions.create(
      major: next_major_version_number,
      minor: 0,
      notes: 'Created via Import Process',
      created_by_id: source_sv_id,
      thank_you_page: data_hash["thank_you_page"]
    )
  end

  def create_text_question(text_question_data, page)
    new_tq = survey_version.text_questions.build(
      answer_type: text_question_data["answer_type"],
      answer_size: text_question_data["answer_size"],
      question_content_attributes: {
        statement: text_question_data["statement"],
        required: text_question_data["required"]
      },
      survey_element_attributes: {
        page: page,
        survey_version: survey_version
      }
    )

    new_tq.save!
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
    return false if export_file.nil?
    data_hash["pages"].each do |page|
      new_page = create_page page["page_number"]

      page["survey_elements"].each do |element|

        if element["assetable_type"] == "ChoiceQuestion"
          create_choice_question(element, new_page)
        end

        if element["assetable_type"] == "TextQuestion"
          create_text_question(element, new_page)
        end

        if element["assetable_type"] == "MatrixQuestion"
          create_matrix_question(element, new_page)
        end

        if element["assetable_type"] == "Asset"
          create_asset(element, new_page)
        end
      end
    end

    set_page_level_flow_control
    set_question_level_flow_control
  rescue
    return false
  end

  def set_page_level_flow_control
    data_hash["pages"].each do |page_data|
      next if page_data["next_page"].nil?
      if page_data["page_number"].to_i != (page_data["next_page"].to_i - 1)
        page = survey_version.pages.find_by_page_number(page_data["page_number"].to_i)
        next_page_id = survey_version.pages.find_by_page_number(page_data["next_page"].to_i).id
        page.update_attribute(:next_page_id, next_page_id)
      end
    end
  end

  def set_question_level_flow_control
    choice_answer_page_mappings.each_pair do |choice_answer, page_number|
      next_page_id = survey_version.pages.find_by_page_number(page_number).id
      choice_answer.update_attribute(:next_page_id, next_page_id)
    end
  end

  def self.import(survey, export_file, source_sv_id = nil)
    new(survey, export_file, source_sv_id).import
  end
end
