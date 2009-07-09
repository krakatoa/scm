class AddReferenciasEnLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :vigilador_id, :integer
    add_column :logs, :dato_id, :integer
  end

  def self.down
  end
end
