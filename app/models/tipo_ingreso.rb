class TipoIngreso < ActiveRecord::Base
  set_table_name :tipos_ingreso

  validates_presence_of :etiqueta

  @@tipos_ingreso = ["normal", "no ingreso", "renovacion", "perdida"]

  def self.tipos_ingreso
    @@tipos_ingreso
  end

  def normal?;      self.etiqueta == "normal";      end
  def no_ingreso?;  self.etiqueta == "no ingreso";  end
  def renovacion?;  self.etiqueta == "renovacion";  end
  def perdida?;     self.etiqueta == "perdida";     end
end