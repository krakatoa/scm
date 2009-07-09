class CreateGrupos < ActiveRecord::Migration
  def self.up
    create_table :grupos do |t|
      t.string :namespace
      t.string :etiqueta
      t.integer :parent_id, :default => nil
      t.string :user_kinds
    end
  end

  def self.down
    drop_table :grupos
  end
end
