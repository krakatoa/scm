class CreateVariacionPorcentajeGestion < ActiveRecord::Migration
  def self.up
    create_table :variacion_porcentaje_gestion do |t|
      t.float     :porcentaje
      t.datetime  :fecha
    end

    VariacionPorcentajeGestion.delete_all
    VariacionPorcentajeGestion.create(:porcentaje => 15, :fecha => Time.now)
  end

  def self.down
    drop_table :variacion_porcentaje_gestion
  end
end
