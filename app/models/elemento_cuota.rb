class ElementoCuota < Elemento
  def etiqueta
     "Cuota #{self.mes}-#{self.ano}"
   end

  def build_vigilador_dato(vigilador)
    Cuota.new(:vigilador => vigilador, :elemento => self)
  end
end