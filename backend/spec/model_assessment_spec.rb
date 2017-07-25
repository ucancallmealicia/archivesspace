require 'spec_helper'
require 'assessment_spec_helper'

describe 'Assessment model' do

  before(:all) do
    AssessmentSpecHelper.setup_global_ratings
  end

  let(:resource) { create_resource }
  let(:surveyor) { create(:json_agent_person) }

  it "can create an assessment" do
    assessment = Assessment.create_from_json(build(:json_assessment, {
                                                     'records' => [{'ref' => resource.uri}],
                                                     'surveyed_by' => [{'ref' => surveyor.uri}],
                                                   }))

    json = Assessment.to_jsonmodel(assessment.id)
    json.should_not be_nil
    json.records.should_not be_empty
    json.records.first['ref'].should eq(resource.uri)

    json.surveyed_by.should_not be_empty
    json.surveyed_by.first['ref'].should eq(surveyor.uri)
  end


  it "gets back the global rating" do
    assessment = Assessment.create_from_json(build(:json_assessment, {
                                                     'records' => [{'ref' => resource.uri}],
                                                     'surveyed_by' => [{'ref' => surveyor.uri}],
                                                   }))

    json = Assessment.to_jsonmodel(assessment.id)

    json.ratings.length.should eq(1)
    json.ratings[0]['value'].should be(nil)
  end


  it "sets a value for a rating and gets it back" do
    definitions = AssessmentAttributeDefinitions.get($repo_id)

    assessment = Assessment.create_from_json(
      build(:json_assessment, {
              'records' => [{'ref' => resource.uri}],
              'surveyed_by' => [{'ref' => surveyor.uri}],
              'ratings' => [
                {
                  "definition_id" => definitions.definitions[0].fetch(:id),
                  "value" => "5",
                }
              ],
            })
    )

    json = Assessment.to_jsonmodel(assessment.id)

    json.ratings.length.should eq(1)
    json.conservation_issues.length.should eq(0)
    json.formats.length.should eq(0)

    json.ratings[0]['value'].should eq('5')
  end


  describe "repository attributes" do

    before(:each) do
      JSONModel(:assessment_attribute_definitions)
        .from_hash('definitions' => [
                     {
                       'label' => 'Rating',
                       'type' => 'rating',
                     },
                     {
                       'label' => 'Format',
                       'type' => 'format',
                     },
                     {
                       'label' => 'Conservation Issue',
                       'type' => 'conservation_issue',
                     }
                   ])
        .save
    end


    it "successfully sets a value for a repository attribute" do
      assessment = Assessment.create_from_json(build(:json_assessment, {
                                                       'records' => [{'ref' => resource.uri}],
                                                       'surveyed_by' => [{'ref' => surveyor.uri}],
                                                     }))

      json = Assessment.to_jsonmodel(assessment.id)

      json.ratings.length.should eq(2) # one global, one repo
      json.formats.length.should eq(1)
      json.conservation_issues.length.should eq(1)

      # Set a value
      json.formats[0]['value'] = 'true'

      Assessment[assessment.id].update_from_json(json)

      json = Assessment.to_jsonmodel(assessment.id)
      json.formats[0]['value'].should eq('true')
    end

  end

end
