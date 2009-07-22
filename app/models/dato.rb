class Dato < ActiveRecord::Base
  belongs_to :elemento
  belongs_to :vigilador

  validates_presence_of :elemento_id, :vigilador_id

  def facturar!
    self.facturado = true
    self.save
  end

  def valor
    if self.elemento.is_a? ElementoConCosto
      return self.costo
    elsif self.elemento.is_a? ElementoSimple
      return self.costo
    elsif self.elemento.is_a? ElementoFecha
      return self.fecha
    elsif self.elemento.is_a? ElementoFormula
      if self.elemento.formula.match(/\+/)
        operandos = self.elemento.formula.split(/\+/)
        operandos = operandos.collect { |o|
          if o.match(/\$/)
            self.vigilador.datos.select{|d| d.elemento.id == o.gsub("$", "").to_i}[0].costo
          else
            o.to_i
          end
        }
        return operandos.inject(res=0){|res,sumando| res+sumando}
      elsif self.elemento.formula.match(/\-/)
        operandos = self.elemento.formula.split(/\-/)
        operandos = operandos.collect { |o|
          if o.match(/\$/)
            self.vigilador.datos.select{|d| d.elemento.id == o.gsub("$", "").to_i}[0].costo
          else
            o.to_i
          end
        }
        return operandos[0] - operandos[1]
      elsif self.elemento.formula.match(/\*/)
        elemento_id, k = self.elemento.formula.split(/\*/)
        return self.vigilador.datos.select{|d| d.elemento.id == elemento_id.to_i}[0].valor * k.to_f
      end
    elsif self.elemento.is_a? ElementoGestionTramites
      return self.costo
    elsif self.elemento.is_a? ElementoCuota
      return self.costo
    elsif self.elemento.is_a? ElementoConBandera
      if self.facturado != nil
        return (self.facturado? ? "Si" : "No")
      else
        return self.costo
      end
    end
  end

  def costo=(arg="")
    if self.elemento.is_a? ElementoConBandera
      if arg.is_a? String
        if arg.strip.match(/^[Ss][Ii]$/)
          self.facturado = true
        elsif arg.strip.match(/^[Nn][Oo]$/)
          self.facturado = false
        end
      end
    end
    super
  end
end
