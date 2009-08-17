=begin
Introduccion del Objeto: Acceso

Maneja el Acceso a un Dato, Cuota, o modificacion de Vigilador.
-> Hace de vinculo entre un campo de dato y un usuario.

Uso:
El usuario de Sueldos A, elige la solapa de Logistica,
Los Accesos que permiten la lectura por parte del personal de Sueldos,
(pueden permitir la escritura al otro personal especifico)
Se muestra el campo solicitado unicamente.
Por ejemplo, un Acceso puede vincular al ElementoCuota X que refiera al mes 1 y ano 2020, con la lectura del campo recursos_humanos, y al mismo tiempo restringir la visibilidad al personal de RecursosHumanos+Sueldos, y la escritura solo permitida a RecursosHumanos.

0 - Ningun permiso
1 - Permiso de Lectura
2 - Permiso de Escritura
-> 3 Permiso de Lectoescritura
4 - Permiso de Eliminacion
-> 7 Permiso de Lectura, Modificacion y Eliminacion

rSCLRA
(Resumen, Sueldos, Contabilidad, Logistica, RecursosHumanos, Admin)

Uso:
113317

=end

class Acceso < ActiveRecord::Base
  named_scope :with_elemento, lambda { |e| { :conditions => { :elemento_id => e.id } }}

  belongs_to :grupo
  belongs_to :elemento

  def self.crear_accesos_a_cuota(elemento_cuota)
    self.create!( :elemento => elemento_cuota,
                    :grupo => Grupo.find(3),
                    :campo => 'total',
                    :acceso => "111111" ) # Solapa Resumen Cuotas
    self.create!( :elemento => elemento_cuota,
                    :grupo => Grupo.find(6),
                    :campo => 'recursos_humanos',
                    :acceso => "113137" ) # Solapa RRHH Cuotas
    self.create!( :elemento => elemento_cuota,
                    :grupo => Grupo.find(9),
                    :campo => 'logistica',
                    :acceso => "113317" ) # Solapa Logistica Cuotas
  end

  def permiso_lectura?(user)
    return true unless self.acceso
    acl = self.acceso.chars.to_a[Acceso.get_acl_index(user.class)].to_i
    acl_array = Acceso.get_acl_array(acl)
    begin
      return acl_array[0] == 1
    rescue
      return false
    end
  end

  def permiso_escritura?(user)
    return true if self.acceso.blank?
    acl = self.acceso.chars.to_a[Acceso.get_acl_index(user.class)].to_i
    acl_array = Acceso.get_acl_array(acl)
    begin
      return acl_array[1] == 1
    rescue
      return false
    end
  end

  def permiso_eliminacion?(user)
    return false unless self.acceso
    acl = self.acceso.chars.to_a[Acceso.get_acl_index(user.class)].to_i
    acl_array = Acceso.get_acl_array(acl)
    begin
      return acl_array[2] == 1
    rescue
      return false
    end
  end

  private
  def self.get_acl_array(val)
    acl_array = []
    while val > 0 do
      acl_array.push(val % 2)
      val /= 2
    end
    return acl_array
  end

  def self.get_acl_index(klass)
    pos = nil
    if klass == SueldosUser
      pos = 1
    elsif klass == ContabilidadUser
      pos = 2
    elsif klass == LogisticaUser
      pos = 3
    elsif klass == RecursosHumanosUser
      pos = 4
    elsif klass == AdminUser
      pos = 5
    end
    return pos
  end
end
