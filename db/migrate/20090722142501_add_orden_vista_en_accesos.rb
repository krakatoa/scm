class AddOrdenVistaEnAccesos < ActiveRecord::Migration
  def self.up
    add_column :grupos, :orden_vista, :integer, :default => 0
    add_column :accesos, :orden_vista_en_grupo, :integer, :default => 0

    ind_orden_vista = 0
    grupo_resumen = Grupo.all(:conditions => {:etiqueta => "Resumen", :parent_id => nil})[0]
    grupo_resumen.children_groups.each { |g|
      g.orden_vista = ind_orden_vista
      g.save
      ind_orden_vista += 1

      ind_orden_vista_en_grupo = 0
      g.accesos.each { |a| a.orden_vista_en_grupo = ind_orden_vista_en_grupo; a.save; ind_orden_vista_en_grupo += 1 }
    }

    grupo_recursos_humanos = Grupo.all(:conditions => {:etiqueta => "RRHH", :parent_id => nil})[0]
    grupo_recursos_humanos.children_groups.each { |g|
      g.orden_vista = ind_orden_vista
      g.save
      ind_orden_vista += 1
      
      ind_orden_vista_en_grupo = 0
      g.accesos.each { |a| a.orden_vista_en_grupo = ind_orden_vista_en_grupo; a.save; ind_orden_vista_en_grupo += 1 }
    }

    grupo_logistica = Grupo.all(:conditions => {:etiqueta => "Logistica", :parent_id => nil})[0]
    grupo_logistica.children_groups.each { |g|
      g.orden_vista = ind_orden_vista
      g.save
      ind_orden_vista += 1
      
      ind_orden_vista_en_grupo = 0
      g.accesos.each { |a| a.orden_vista_en_grupo = ind_orden_vista_en_grupo; a.save; ind_orden_vista_en_grupo += 1 }
    }

    grupo_sueldos = Grupo.all(:conditions => {:etiqueta => "Sueldos", :parent_id => nil})[0]
    grupo_sueldos.children_groups.each { |g|
      g.orden_vista = ind_orden_vista
      g.save
      ind_orden_vista += 1

      ind_orden_vista_en_grupo = 0
      g.accesos.each { |a| a.orden_vista_en_grupo = ind_orden_vista_en_grupo; a.save; ind_orden_vista_en_grupo += 1 }
    }
  end

  def self.down
    remove_column :grupos, :orden_vista
    remove_column :accesos, :orden_vista_en_grupo
  end
end
