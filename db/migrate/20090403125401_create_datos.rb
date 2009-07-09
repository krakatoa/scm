class CreateDatos < ActiveRecord::Migration
  def self.up
    create_table :datos do |t|
      t.integer :vigilador_id
      t.integer :elemento_id
      t.date :fecha, :default => nil
      t.float :costo, :default => 0
      t.boolean :facturado, :default => nil
    end
  end

  def self.down
    drop_table :datos
  end
end
