class CreateCuotas < ActiveRecord::Migration
  def self.up
    create_table :cuotas do |t|
      t.integer :vigilador_id
      t.integer :elemento_id
      t.integer :recursos_humanos, :default => 0
      t.integer :logistica, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :cuotas
  end
end
