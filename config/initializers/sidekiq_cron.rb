require 'sidekiq/cron/job'

# Definir trabajos programados
# La línea Cron siempre se evalúa con respecto a la hora UTC, por eso, para enviar a las 07:00 AM según
# la zona horaria de America/Chile (timezone -03:00), se debe especificar a las 10:00 AM en el cron
# Obs.: Tuve muchos problemas para crear el cron, un tip para comprobar que funciona es ejecutando
#       desde la consola job = Sidekiq::Cron::Job.new, job.valid? y job.errores para comprobar
#       los problemas. En este caso el problema era una versión incompatible de rufus-scheduler.
#       También probé con sidekiq-scheduler pero no hubo caso, luego encontré la documentación correcta, pero
#       sidekiq-cron es más simple de usar y muestra los jobs en la ui de sidekiq, sidekiq-scheduler se integra
#       con la ui de sidekiq sólo en versiones más recientes.
Sidekiq::Cron::Job.create(
  name: 'Daily Sale Orders Report at 07:00 AM',
  cron: '0 10 * * *', # Expresión cron
  class: 'DailySaleOrdersReportWorker' # Nombre de la clase del worker a ejecutar
)

Sidekiq::Cron::Job.create(
  name: 'Daily Sale Orders Report at 03:00 AM',
  cron: '20 2 * * *', # Expresión cron
  class: 'DailySaleOrdersReportWorker' # Nombre de la clase del worker a ejecutar
)
