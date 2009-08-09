class TipoIngreso < ActiveRecord::Base
  set_table_name :tipos_ingreso

  validates_presence_of :etiqueta

  @@tipos_ingreso = []
  TipoIngreso.all.each do |tipo_ingreso|
    @@tipos_ingreso.push tipo_ingreso.etiqueta
    etiqueta = tipo_ingreso.etiqueta
    underscore = etiqueta.gsub(" ", "_")
    eval %{
      def self.#{underscore}_id
        #{tipo_ingreso.id}
      end

      def #{underscore}?
        self.etiqueta.eql?("#{etiqueta}")
      end
    }
  end

  def self.tipos_ingreso
    @@tipos_ingreso
  end
end