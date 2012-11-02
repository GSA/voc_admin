require 'spec_helper'

describe Rule do
	it { should validate_presence_of(:name) }
	it { should validate_presence_of(:rule_order) }

	it "validates uniqueness of rule_order" do
		Rule.new(:rule_order => 1, :name => "whatever", :survey_version_id => 1).save(:validate => false)
		should validate_uniqueness_of(:rule_order).scoped_to(:survey_version_id)
	end

	it { should validate_numericality_of(:rule_order) }

	it { should validate_presence_of(:survey_version) }

	it { should validate_presence_of(:execution_triggers) }

	context "clone_me" do
	#  id                :integer(4)      not null, primary key
	#  name              :string(255)     not null
	#  created_at        :datetime
	#  updated_at        :datetime
	#  survey_version_id :integer(4)      not null
	#  rule_order        :integer(4)      not null
	#  clone_of_id       :integer(4)
	#  action_type       :string(255)     default("db")
		let(:rule) { Rule.new({name: "Rspec Rule", survey_version_id: 1, rule_order: 1, clone_of_id: nil, action_type: "db"}) }
		let(:target_sv) { mock_model(SurveyVersion, :rules => mock("rules", :find_by_name => nil, :count => 0)) }

		before(:each) { Rule.any_instance.stub(:save!).and_return(true) } # Stub the creation of the rule

		it "should clone the rule attributes" do
			# Create a rule to clone
			rule.save(validate: false)

			# clone the rule
			cloned_rule = rule.clone_me(target_sv)

			# Test the cloned rule's attributes
			cloned_rule.attributes.except("clone_of_id", "survey_version_id", "id").should == rule.attributes.except("clone_of_id", "survey_version_id", "id")
		end	

		it "should set the clone_of_id of the new rule to be the id of original rule" do
			# Create a rule to clone
			rule.save(validate: false)

			# clone the rule
			cloned_rule = rule.clone_me(target_sv)

			cloned_rule.clone_of_id.should == rule.id			
		end


		##########################################################
		# These tests really should be on the criterion model.   #
		# In order to do that, the rule clone should be          #
		# refactored out so the methods are in the correct place #
		##########################################################

		it "should clone the criteria attributes" do
			# Add a criteria to the rule before cloning
			rule.criteria.build({
				source_id: 1,
				conditional_id: 10,
				value: "whatever",
				source_type: "QuestionContent"
			})

			rule.save(validate: false)

			rule.criteria.first.stub_chain(:source, :find_my_clone_for).and_return mock_model(QuestionContent, :id => 2)

			cloned_rule = rule.clone_me(target_sv)

			cloned_rule.criteria.first.attributes.except("id", "clone_of_id", "rule_id", "source_id").should == rule.criteria.first.attributes.except("id", "clone_of_id", "rule_id", "source_id")
		end

		it "should set the clone_of_id for the criterion to be the id of the original criterion" do
			# Add a criteria to the rule before cloning
			rule.criteria.build({
				source_id: 1,
				conditional_id: 10,
				value: "whatever",
				source_type: "QuestionContent"
			})

			rule.save(validate: false)

			rule.criteria.first.stub_chain(:source, :find_my_clone_for).and_return mock_model(QuestionContent, :id => 2)
			

			cloned_rule = rule.clone_me(target_sv)

			cloned_rule.criteria.first.clone_of_id.should == rule.criteria.first.id			
		end

		it "should clone the action attributes" do
			# Add an action before cloning
			rule.actions.build({
				display_field_id: 1,
				value: "whatever",
				value_type: "Response"
			})

			rule.save(validate: false)

			DisplayField.stub(:find_by_survey_version_id_and_clone_of_id).and_return mock_model(DisplayField, :id => 1)
			target_sv.stub_chain(:options_for_action_select).and_return [[1, "whatever"]]
			rule.stub_chain(:survey_version, :options_for_action_select).and_return [[1, "whatever"]]


			cloned_rule = rule.clone_me(target_sv)

			cloned_rule.actions.first.attributes.except("id", "clone_of_id", "rule_id").should == rule.actions.first.attributes.except("id", "clone_of_id", "rule_id")		
		end

		it "should set the clone_of_id on the cloned action" do
			# Add an action before cloning
			rule.actions.build({
				display_field_id: 1,
				value: "whatever",
				value_type: "Response"
			})

			rule.save(validate: false)

			DisplayField.stub(:find_by_survey_version_id_and_clone_of_id).and_return mock_model(DisplayField, :id => 1)
			target_sv.stub_chain(:options_for_action_select).and_return [[1, "whatever"]]
			rule.stub_chain(:survey_version, :options_for_action_select).and_return [[1, "whatever"]]


			cloned_rule = rule.clone_me(target_sv)

			cloned_rule.actions.first.clone_of_id.should == rule.actions.first.id			
		end
	end


end