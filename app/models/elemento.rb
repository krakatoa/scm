class Elemento < ActiveRecord::Base
  has_and_belongs_to_many :grupos

  validates_presence_of :etiqueta

  self.inheritance_column = "elemento_kind"
end
