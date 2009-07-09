class CreateVigiladores < ActiveRecord::Migration
  def self.up
    create_table :vigiladores do |t|
      t.string :legajo
      t.string :apellido
      t.string :nombre
      t.string :dni
      t.date :fecha_ingreso, :default => nil
      t.integer :tipo_ingreso_id, :default => nil
      
      t.integer :editando

      t.timestamps
    end
    add_index "vigiladores", ["legajo", "dni"]
  end

  def self.down
    drop_table :vigiladores
  end
end
