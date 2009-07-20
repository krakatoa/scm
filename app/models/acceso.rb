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
end
