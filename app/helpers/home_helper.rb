module HomeHelper
  def active_home_menu?
    "navbar-item-active" if request.path == "/"
  end
end
