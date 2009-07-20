class ElementoCuota < Elemento
  after_create :actualizar_vigiladores

  def etiqueta
     "Cuota #{self.mes}-#{self.ano}"
   end

  def build_vigilador_dato(vigilador)
    Cuota.new(:vigilador => vigilador, :elemento => self)
  end

  def self.agregar_mes
    ultimo = ElementoCuota.all(:order_by => [:ano, :mes], :order_as => :desc).first
    nuevo_ano = ultimo.ano
    nuevo_mes = ultimo.mes + 1
    if nuevo_mes > 12
      nuevo_mes = 1
      nuevo_ano += 1
    end
    nueva_cuota = ElementoCuota.create!(:mes => nuevo_mes, :ano => nuevo_ano)
    Acceso.crear_accesos_a_cuota nueva_cuota
  end

  private
    def actualizar_vigiladores
      Vigilador.all.each { |v|
        o = self.build_vigilador_dato(v)
        o.save!
      }
    end
end