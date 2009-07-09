class CreateElementosGrupos < ActiveRecord::Migration
  def self.up
    create_table :elementos_grupos, :id => false do |t|
      t.integer :grupo_id
      t.integer :elemento_id
    end
  end

  def self.down
    drop_table :elementos_grupos
  end
end
