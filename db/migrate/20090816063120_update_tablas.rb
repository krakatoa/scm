class UpdateTablas < ActiveRecord::Migration
  def self.up
    change_table :datos do |t|
      t.timestamps
    end

    add_index :elementos, "etiqueta"
    add_index :vigiladores, "apellido"
    add_index :vigiladores, "nombre"
    add_index :vigiladores, "legajo"
    add_index :vigiladores, "dni"
  end

  def self.down
  end
end
