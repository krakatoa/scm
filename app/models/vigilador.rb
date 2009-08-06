class Vigilador < ActiveRecord::Base
  set_table_name :vigiladores

  has_many :datos, :include => [:elemento]
  has_many :cuotas, :include => [:elemento]
  belongs_to :tipo_ingreso

  validates_presence_of :apellido, :nombre, :dni, :message => "no puede estar en blanco"
  validates_uniqueness_of :dni, :message => "ingresado ya existe"

  named_scope :with_user_editando, lambda { |user| { :conditions => { :editando => user } }}
  # TODO check! @@
  named_scope :no_ingreso, :conditions => ["tipo_ingreso_id = ?", TipoIngreso.no_ingreso_id]

  def after_create
    Elemento.all.each do |e|
      o = e.build_vigilador_dato(self)
      o.save!
    end
  end

  def bloquear_user(user)
    self.editando = user.id
    self.save
  end

  def desbloquear!
    self.editando = false
    self.save
  end

  def nuevo?
    self.tipo_ingreso.blank?
  end

  def no_ingreso!
    self.tipo_ingreso_id = TipoIngreso.no_ingreso_id
    self.save
  end

  def no_ingreso?
    self.tipo_ingreso == TipoIngreso.no_ingreso_id
  end

  def aplicar_gestion_tramites!
    id_total_suma_gastada = 34 # deberia estar referenciado desde el mismo campo de GestionTramites (en el YAML de elementos)

    # TODO Check queries!
    total_suma_gastada_dato = self.datos.select{|d| d.read_attribute(:elemento_id) == id_total_suma_gastada}[0]
    gestion_tramites_dato = self.datos.select{|d| d.elemento.is_a? ElementoGestionTramites}[0]
    #gestion_tramites_dato = self.datos.select{|d| d.id == gestion_dato_id}[0]
    gestion_tramites_dato.costo = total_suma_gastada_dato.valor + ((total_suma_gastada_dato.valor * VariacionPorcentajeGestion.porcentaje_actual) / 100).to_i
    gestion_tramites_dato.save!
  end

  def descontar_cuotas!(total, mes_inicial, flags, cant_cuotas=1)
    if flags == "rrhh"
      campo = :recursos_humanos
    elsif flags == "logistica"
      campo = :logistica
    end
    valor_cuota = total / cant_cuotas
    a_descontar = self.cuotas.select {|c| (c.elemento.mes >= mes_inicial) && (c.elemento.mes < mes_inicial + cant_cuotas)}
    return false if a_descontar.size != cant_cuotas

    a_descontar.each do |cuota|
      cuota.write_attribute(campo, valor_cuota)
      cuota.save!
    end
  end
end
