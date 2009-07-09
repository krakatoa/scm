class Dato < ActiveRecord::Base
  belongs_to :elemento
  belongs_to :vigilador

  validates_presence_of :elemento_id, :vigilador_id

#  named_scope :with_grupo_elementos, lambda { |ge| { :conditions => "elemento_id " } }

  def facturar!
    self.facturado = true
    self.save
  end

  def valor
    # TODO bien no, pero esto no puede ir a parar a la clase Elemento, se me ocurre algo asi como que devuelva
    # un proc de la manera de conseguir el valor,
    # o tal vez pueda ir bien devolver un Symbol que aclare el campo a buscar:
    # algo asi:
    # self.read_attribute(self.elemento.campo)
    #
    # entonces, supongamos un dato con elemento ElementoFecha,
    # con la clase para ElementoFecha definiendo un campo:
    # def campo; :fecha; end
    #
    # el metodo para obtener el valor de un campo se traduciria en:
    # 
    # def valor
    #   self.read_attribute(self.elemento.campo) => self.read_attribute(:fecha)
    #
    # para pensarlo, porque habria que ver como resolver las formulas
    # YA SE!
    # es sencillo,
    #
    # en ElementoFormula defino:
    # def campo; self.formula; end
    #
    # Restaria definir,
    # si el campo (ya no seria campo, pero no importa)
    # Si el campo del elemento, es un simbolo,
    # entonces traigo un atributo del dato
    # si es una formula, la parseo y la resuelvo, usando los valores de cada uno de los datos
    
    if self.elemento.is_a? ElementoConCosto
      return self.costo
    elsif self.elemento.is_a? ElementoSimple
      return self.costo
    elsif self.elemento.is_a? ElementoFecha
      return self.fecha
    elsif self.elemento.is_a? ElementoFormula
      # TODO primera version cabezoide, en este momento no me da para ponerme detallista :)
      # hace falta planear un modulo de formulas
      # que se manejen algo asi como:
      # 
      # $14 + 4 ==> dato.con_elemento(14)
      # SUM( $(1..3) ) ==> dato.con_elemento(1) + dato.con_elemento(2) + dato.con_elemento(3)
      #

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