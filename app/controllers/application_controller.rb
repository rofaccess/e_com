class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_paper_trail_whodunnit

  def check_admin
    redirect_to root_path unless current_user.is_admin?
  end

  def check_client
    redirect_to root_path unless current_user.is_client?
  end
end
