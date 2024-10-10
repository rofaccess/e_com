class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :is_admin
  before_save :set_name

  scope :only_admins, -> { where(is_admin: true) }

  def is_admin?
    is_admin
  end

  def is_client?
    !is_admin?
  end

  def self.admin_emails(except_email=nil)
    admin_emails = User.only_admins
    admin_emails = admin_emails.where("email != ?", except_email) if except_email
    admin_emails.pluck(:email)
  end

  private

  def set_name
    self.name = self.email.split('@')[0].capitalize
  end
end
