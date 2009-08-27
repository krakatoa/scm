class Cuota < ActiveRecord::Base
  belongs_to :vigilador, :touch => true
  belongs_to :elemento

  attr_reader :total

  def mes; elemento.mes; end
  def ano; elemento.ano; end

  def total
    self.recursos_humanos + self.logistica
  end
end
