class Cuota < ActiveRecord::Base
  belongs_to :vigilador
  belongs_to :elemento

  attr_reader :total

  def total
    self.recursos_humanos + self.logistica
  end
end
