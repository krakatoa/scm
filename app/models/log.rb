class Log < ActiveRecord::Base
  @@log_types = { :creacion => 1,
                  :alta => 2,
                  :desercion => 3,
                  :modificacion_dato => 4,
                  :facturacion => 5,
                  :variacion_porcentaje_descuento => 6 }

  belongs_to :user
  belongs_to :vigilador
  belongs_to :dato

  validates_presence_of :user_id
  validates_presence_of :log_type

  def self.log(user, type, vigilador=nil, dato=nil, observacion="")
    Log.create!(:user => user,
                :log_type => self.log_types[type],
                :vigilador => vigilador,
                :dato => dato,
                :observacion => observacion)
  end

  def self.log_types
    @@log_types
  end
end