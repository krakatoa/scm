class CreateTipoIngreso < ActiveRecord::Migration
  def self.up
    create_table :tipos_ingreso do |t|
      t.string :etiqueta
    end
    add_index "tipos_ingreso", ["etiqueta"]

    TipoIngreso.tipos_ingreso.each do |tipo_ingreso|
      TipoIngreso.create(:etiqueta => tipo_ingreso)
    end
  end

  def self.down
    drop_table :tipos_ingreso
  end
end