class TipoIngreso < ActiveRecord::Base
  set_table_name :tipos_ingreso

  validates_presence_of :etiqueta

  #@@tipos_ingreso = TipoIngreso.all.collect{|t| t.etiqueta}#["normal", "no ingreso", "renovacion", "perdida"]

  @@tipos_ingreso = []
  TipoIngreso.all.each do |tipo_ingreso|
    @@tipos_ingreso.push tipo_ingreso.etiqueta
    eval %{
      def self.#{tipo_ingreso.etiqueta.gsub(" ", "_")}_id
        #{tipo_ingreso.id}
      end
    }
  end

  def self.tipos_ingreso
    @@tipos_ingreso
  end

  def normal?;      self.etiqueta == "normal";      end
  def no_ingreso?;  self.etiqueta == "no ingreso";  end
  def renovacion?;  self.etiqueta == "renovacion";  end
  def perdida?;     self.etiqueta == "perdida";     end
end