require 'rails_helper'

RSpec.describe Client, :type => :model do
  fixtures :clients

  subject(:client) {
    Client.new(name: "Dean", document_number: "22222")
  }

  it "save valid record" do
    expect(client.save).to be(true)
  end

  it "save duplicate name" do
    client.name = "John"
    expect(client.save).to be(true)
  end

  it "not save duplicate name and document_number" do
    client.name = "John"
    client.document_number = "11111"
    expect {client.save}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
