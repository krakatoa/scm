class Grupo < ActiveRecord::Base
  belongs_to :parent_group, :class_name => 'Grupo', :foreign_key=>"parent_id"
  has_many :children_groups, :class_name => 'Grupo', :foreign_key=>"parent_id", :include => [:parent_group]

  has_many :accesos, :include => [:elemento]
  has_many :elementos, :through => :accesos

  named_scope :parents, {:conditions => {:parent_id => nil}}
  named_scope :children, {:conditions => ["parent_id is not ?", nil]}

  validates_presence_of :etiqueta

  # TODO validates_presence_of "controller" if parent?

  def allowed_user_kinds
    if self.user_kinds
      self.user_kinds.split(",").collect(&:strip).collect(&:constantize)
    elsif self.parent_group
      self.parent_group.allowed_user_kinds
    else
      nil
    end
  end

  def user_allowed?(user)
    self.allowed_user_kinds.include? user.class
  end

  def self.user_allowed(user)
    self.all.select { |g| g.user_allowed?(user) }
  end
end
