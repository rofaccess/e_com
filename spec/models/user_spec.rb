require 'rails_helper'

RSpec.describe User, :type => :model do
  fixtures :users

  subject(:user) {
    User.new(name: "Bob", email: "bob@bob.com", password: "123456789")
  }

  it "save valid record" do
    expect(user.save).to be(true)
  end

  it "save duplicate name" do
    user.name = "Amy"
    user.email = "amy_amy@email.com"
    expect(user.save).to be(true)
  end

  it "not save duplicate email" do
    user.name = "Amy"
    user.email = "amy@email.com"
    expect {user.save(validate: false)}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
