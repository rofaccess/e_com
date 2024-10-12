if Rails.env.development?
  Bullet.enable = true # enable Bullet gem, otherwise do nothing
  Bullet.alert = true # pop up a JavaScript alert in the browser
  Bullet.bullet_logger = true # log to the Bullet log file (Rails.root/log/bullet.log)
  Bullet.console = true # log warnings to your browser's console.log (Safari/Webkit browsers or Firefox w/Firebug installed)
  Bullet.rails_logger = true #  add warnings directly to the Rails log
  Bullet.add_footer = true # adds the details in the bottom left corner of the page
  # Bullet.raise = true # raise errors, useful for making your specs fail unless they have optimized queries
end
