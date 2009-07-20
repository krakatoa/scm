class AddSuperEdit < ActiveRecord::Migration
  def self.up
    add_column :users, :super_edit, :boolean, :default => false
  end

  def self.down
  end
end
