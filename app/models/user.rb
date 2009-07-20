class User < ActiveRecord::Base
  acts_as_authentic

  def self.kinds; ['Contabilidad', 'Recursos Humanos', 'Logistica', 'Sueldos', 'Admin']; end

  self.inheritance_column = "user_kind"
  validates_presence_of :user_kind
  #TODO
  #validates_inclusion_of :user_kind, :in => User.kinds

  def initialize(params = {})
    super
    self.login ||= "#{self.nombre.downcase.delete(" ")}.#{self.apellido.downcase.delete(" ")}" if self.nombre and self.apellido
    self.password ||= User.random_password
    self.password_confirmation ||= self.password
  end

  def self.load_yml(empresa)
    users = YAML.load(File.read(File.join(RAILS_ROOT, 'config', 'users.yml')))
    sgc = users[empresa]
    sgc.each do |user_params|
      user_params = user_params[1]
      sector = user_params['sector']
      user_params.delete('sector')
      
      sector = "RecursosHumanos" if sector == "RRHH" or sector == "Recursos Humanos"
      sector = "Admin" if sector == "Administrador"
      
      user_kind = "#{sector}User".constantize
      
      user = user_kind.new(user_params)
      puts "#{user.login}:#{user.password} (#{user.class})"
      user.save!
    end
  end

  def self.random_password
    ## Copyright German Hirtz xD.
    password_size = 8 + rand(2)
    sizes = []
    sizes << 1 + rand(password_size - 2)
    sizes << 1 + rand(password_size - 1 - sizes[0])
    sizes << password_size - sizes.sum

    ret = []
    sizes[0].times{ ret << ("a".."z").to_a.rand }
    sizes[1].times{ ret << ("A".."z").to_a.rand }
    sizes[2].times{ ret << ("0".."9").to_a.rand }
    ret.sort_by { 1 - rand(3) }.join
  end

  def has_super_edit?
    self.super_edit
  end
end
