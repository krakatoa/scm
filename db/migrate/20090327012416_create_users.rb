class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :nombre
      t.string :apellido
      t.string :user_kind
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.string :last_login_ip
      t.string :current_login_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
