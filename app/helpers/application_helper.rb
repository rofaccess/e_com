module ApplicationHelper
  def active_menu?(paths)
    paths.each do |path|
      return "navbar-item-active" if request.path.include?(path)
    end
  end

  def unlogged?
    !current_user
  end

  def logged_as_client?
    current_user && current_user.is_client?
  end

  def logged_as_admin?
    current_user && current_user.is_admin?
  end
end
