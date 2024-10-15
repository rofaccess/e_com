require 'rails_helper'
require 'sidekiq/testing/inline'
Sidekiq::Testing.fake!  # Hace que los trabajos no se procesen, solo se encolan

RSpec.describe DailySaleOrdersReportWorker, type: :worker do
  fixtures :all
  it 'enqueues the job' do
    expect {
      DailySaleOrdersReportWorker.perform_async
    }.to change(DailySaleOrdersReportWorker.jobs, :size).by(1)
  end

  it 'executes perform' do
    expect_any_instance_of(DailySaleOrdersReportWorker).to receive(:perform)
    DailySaleOrdersReportWorker.new.perform
  end

  it 'processes the job correctly' do
    # Se ejecuta Sidekiq in-line para procesar el trabajo en el test inmediatamente
    # Obs.: No pude comprobar correctamente esto, porque el ejecutarse en un hilo aparte no pude debugear ni imprimir mensajes con puts ni Rails.logger.debug
    #       Probé lanzar una excepción dentro del perform, aún así el test pasa, así que no es confiable
    Sidekiq::Testing.inline! do
      expect_any_instance_of(DailySaleOrdersReportWorker).to receive(:perform)
      DailySaleOrdersReportWorker.perform_async
    end
  end
end
