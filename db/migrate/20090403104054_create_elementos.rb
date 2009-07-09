class CreateElementos < ActiveRecord::Migration
  def self.up
    create_table :elementos do |t|
      t.string :etiqueta
      t.string :elemento_kind
      t.string :formula, :default => nil
      t.integer :mes, :default => 0
      t.integer :ano, :default => 0

      t.boolean :facturable, :default => false
    end
  end

  def self.down
    drop_table :elementos
  end
end
