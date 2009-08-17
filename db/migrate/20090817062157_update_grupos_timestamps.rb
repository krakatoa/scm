class UpdateGruposTimestamps < ActiveRecord::Migration
  def self.up
    change_table :grupos do |t|
      t.timestamps
    end
  end

  def self.down
  end
end
