require 'rails_helper'

RSpec.describe User, :type => :model do
  fixtures :users

  subject(:user) {
    user = User.new(name: "Bob")
    # No se setea en new para evitar el error:
    # ActiveModel::MassAssignmentSecurity::Error:
    # Can't mass-assign protected attributes: email, password
    user.email = "bob@email.com"
    user
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
    expect {user.save}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
