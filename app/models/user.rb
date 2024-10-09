class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :is_admin
  before_save :set_name

  def is_admin?
    is_admin
  end

  private

  def set_name
    self.name = self.email.split('@')[0].capitalize
  end
end
