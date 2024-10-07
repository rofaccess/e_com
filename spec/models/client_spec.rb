require 'rails_helper'

RSpec.describe Client, :type => :model do
  fixtures :clients

  subject(:client) {
    Client.new(name: "Bob", document_number: "22222")
  }

  it "save valid record" do
    expect(client.save).to be(true)
  end

  it "save duplicate name" do
    client.name = "Amy"
    expect(client.save).to be(true)
  end

  it "not save duplicate name and document_number" do
    client.name = "Amy"
    client.document_number = "11111"
    expect {client.save}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
