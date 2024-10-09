class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_paper_trail_whodunnit
end
