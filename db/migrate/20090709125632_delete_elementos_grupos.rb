class DeleteElementosGrupos < ActiveRecord::Migration
  def self.up
    drop_table :elementos_grupos
  end

  def self.down
    create_table :elementos_grupos, :id => false do |t|
      t.integer :grupo_id
      t.integer :elemento_id
    end
  end
end
