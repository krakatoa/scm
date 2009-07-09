class ElementoCuota < Elemento
  #def initialize
  #  super
  #  self.etiqueta = "Cuota #{self.mes}-#{self.ano}"
  #end

  def etiqueta
    "Cuota #{self.mes}-#{self.ano}"
  end
end