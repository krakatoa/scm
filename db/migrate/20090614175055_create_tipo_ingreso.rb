class CreateTipoIngreso < ActiveRecord::Migration
  def self.up
    create_table :tipos_ingreso do |t|
      t.string :etiqueta
    end
    add_index "tipos_ingreso", ["etiqueta"]

    TipoIngreso.create(:etiqueta => "normal")
    TipoIngreso.create(:etiqueta => "no ingreso")
    TipoIngreso.create(:etiqueta => "renovacion")
    TipoIngreso.create(:etiqueta => "perdida")
    load 'tipo_ingreso.rb'
  end

  def self.down
    drop_table :tipos_ingreso
  end
end