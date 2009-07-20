class Elemento < ActiveRecord::Base
  has_many :accesos
  has_many :grupos, :through => :accesos

  validates_presence_of :etiqueta

  self.inheritance_column = "elemento_kind"

  def build_vigilador_dato(vigilador)
    Dato.new(:vigilador => vigilador, :elemento => self)
  end
end
