require 'spec_helper'

describe 'External Document model' do


  it "Allows an external document to be created" do

    doc = ExternalDocument.create_from_json(JSONModel(:external_document).
                                 from_hash({
                                             "title" => "My external document",
                                             "location" => "http://www.foobar.com",
                                           }))

    expect(ExternalDocument[doc[:id]].title).to eq("My external document")
    expect(ExternalDocument[doc[:id]].location).to eq("http://www.foobar.com")
  end


  it "throws a validation error when external document is missing title" do
    expect {
      doc = ExternalDocument.create_from_json(JSONModel(:external_document).
                                   from_hash({
                                               "location" => "http://www.foobar.com",
                                             }))
    }.to raise_error(JSONModel::ValidationException)
  end


  it "throws a validation error when external document is missing location" do
    expect {
      doc = ExternalDocument.create_from_json(JSONModel(:external_document).
                                   from_hash({
                                               "title" => "My external document",
                                             }))
    }.to raise_error(JSONModel::ValidationException)
  end


end
