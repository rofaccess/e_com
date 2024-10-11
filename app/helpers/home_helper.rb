module HomeHelper
  def active_home_menu?
    "navbar-item-active" if request.path == "/" || request.path.include?("/home")
  end
end
