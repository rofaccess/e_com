class DailySaleOrdersReportWorker
  include Sidekiq::Worker

  # Esperar 10.000 ventas al día parece razonable. Esto se puede agregar en una variable de entorno o
  # en una tabla de configuración, si hubiesen 10.001 ventas, el reporte solo mostraría los primeros 10.000
  REPORT_ROWS = 10000

  def perform
    recipients = User.admin_emails
    date = Time.current.yesterday
    sale_orders = Reports::SaleOrder.sales_for_day(date, REPORT_ROWS)
    Notifier.daily_sale_orders_report_mail(recipients, sale_orders, date).deliver
  end
end
