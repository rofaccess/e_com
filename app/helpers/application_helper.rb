module ApplicationHelper
  def active_menu?(paths)
    paths.each do |path|
      return "navbar-item-active" if request.path.include?(path)
    end
  end
end
