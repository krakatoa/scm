class VariacionPorcentajeGestion < ActiveRecord::Base
  set_table_name :variacion_porcentaje_gestion

  def self.set_porcentaje(valor)
    VariacionPorcentajeGestion.create!(:porcentaje => valor, :fecha => Time.now)
  end

  def self.porcentaje_actual
    VariacionPorcentajeGestion.last.porcentaje
  end
end