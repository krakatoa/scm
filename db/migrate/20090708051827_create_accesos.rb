class CreateAccesos < ActiveRecord::Migration
  def self.up
    drop_table :grupos
    create_table :grupos do |t|
      t.string :namespace
      t.string :etiqueta
      t.integer :parent_id, :default => nil
      t.string :user_kinds
    end

    create_table :accesos do |t|
      t.integer :elemento_id, :null => false
      t.integer :grupo_id, :null => false
      t.string :campo, :default => nil
      t.string :acceso#, :null => false

      t.timestamps
    end

    resumen = Grupo.create( :etiqueta => "Resumen",
                  :namespace => "resumen",
                  :user_kinds => "AdminUser, ContabilidadUser, RecursosHumanosUser, LogisticaUser, SueldosUser" )
    solapa_resumen = Grupo.create( :etiqueta => "Resumen",
                  :parent_group => resumen )
    solapa_resumen_cuotas = Grupo.create( :etiqueta => "Cuotas",
                  :parent_group => resumen )
    rrhh = Grupo.create( :etiqueta => "RRHH",
                  :namespace => "recursos_humanos",
                  :user_kinds => "AdminUser, ContabilidadUser, RecursosHumanosUser" )
    solapa_rrhh_costos = Grupo.create( :etiqueta => "Costos",
                  :parent_group => rrhh )
    solapa_rrhh_cuotas = Grupo.create( :etiqueta => "Cuotas",
                  :parent_group => rrhh )
    logistica = Grupo.create( :etiqueta => "Logistica",
                  :namespace => "logistica",
                  :user_kinds => "AdminUser, ContabilidadUser, LogisticaUser" )
    solapa_logistica_costos = Grupo.create( :etiqueta => "Costos",
                  :parent_group => logistica )
    solapa_logistica_cuotas = Grupo.create( :etiqueta => "Cuotas",
                  :parent_group => logistica )
    sueldos = Grupo.create( :etiqueta => "Sueldos",
                  :namespace => "sueldos",
                  :user_kinds => "AdminUser, SueldosUser" )
    solapa_sueldos_bajas = Grupo.create( :etiqueta => "Bajas",
                  :parent_group => sueldos )

    # costos
    (1..35).each { |e| Acceso.create(:elemento => Elemento.find(e), :grupo => solapa_resumen) }
    (1..35).each { |e| Acceso.create(:elemento => Elemento.find(e), :grupo => solapa_rrhh_costos) }

    # logistica
    (37..38).each { |e| Acceso.create(:elemento => Elemento.find(e), :grupo => solapa_logistica_costos) }

    # saldos
    (39..41).each { |e| Acceso.create(:elemento => Elemento.find(e), :grupo => solapa_sueldos_bajas) }

    # cuotas
    #(resumen, Sueldos, Contabilidad, Logistica, RecursosHumanos, Admin)
    Acceso.create(:elemento => ElementoDescuentoRecursosHumanos.first, :grupo => solapa_rrhh_cuotas)
    Acceso.create(:elemento => ElementoDescuentoLogistica.first, :grupo => solapa_logistica_cuotas)
    (43..54).each { |e| Acceso.create(:elemento => Elemento.find(e),
                                    :grupo => solapa_resumen_cuotas,
                                    :campo => 'total',
                                    :acceso => "111111" ) }
    (43..54).each { |e| Acceso.create(:elemento => Elemento.find(e),
                                    :grupo => solapa_rrhh_cuotas,
                                    :campo => 'recursos_humanos',
                                    :acceso => "113137" ) }
    (43..54).each { |e| Acceso.create(:elemento => Elemento.find(e),
                                    :grupo => solapa_logistica_cuotas,
                                    :campo => 'logistica',
                                    :acceso => "113317" ) }
  end

  def self.down
    drop_table :accesos
  end
end
