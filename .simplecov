SimpleCov.profiles.define "e_com" do
  puts "require simplecov"

  ## Se usa el perfil rails porque ya filtra ciertas carpetas, por ejemplo la carpeta test no debe incluirse
  ## en el analisis de cobertura y no aparecerá en el reporte de cobertura
  load_profile "rails"

  ## Si se quisiera filtrar alguna carpeta para que no se muestre en el reporte de cobertura
  # add_filter %r{^/test/}

  ## El perfil rails incluye los siguientes grupos y al filtrarlos se seguirán mostrando en el reporte de cobertura
  ## pero no afectarán al porcentaje de cobertura
  add_filter "channels"

  ## Se puede limpiar lo indicado por el perfil Rails, de este modo se puede hacer desaparecer los grupos que no se
  ## suelen utilizar como Channels y  Mailers del reporte de cobertura. Sólo que al limpiar los grupos por defecto de
  ## Rails se deben agregar todos los grupos manualmente usando add_group
  # groups.clear

  ## Agregar otros grupos
  # add_group 'Lib', 'lib'
end
