class PopulateElementos < ActiveRecord::Migration
  def self.up
    drop_table :elementos
    create_table :elementos do |t|
      t.string :etiqueta
      t.string :elemento_kind
      t.string :formula, :default => nil
      t.integer :mes, :default => 0
      t.integer :ano, :default => 0

      t.boolean :facturable, :default => false
    end
    ElementoFecha.create!(:etiqueta => "Baja")
    ElementoFecha.create!(:etiqueta => "Fecha Curso")
    ElementoSimple.create!(:etiqueta => "Curso CABA 60 Horas", :facturable => true)
    ElementoSimple.create!(:etiqueta => "Curso PBA", :facturable => true)
    ElementoSimple.create!(:etiqueta => "Doble Curso", :facturable => true)
    ElementoSimple.create!(:etiqueta => "Curso Renovacion CABA 35 Horas", :facturable => true)
    ElementoConCosto.create!(:etiqueta => "Psicologo")
    ElementoConCosto.create!(:etiqueta => "Clinico")
    ElementoConCosto.create!(:etiqueta => "Laboratorio")
    if RAILS_ENV=="ci5_production"
      ElementoConCosto.create!(:etiqueta => "Libreta Sanitaria")
    end
    ElementoConCosto.create!(:etiqueta => "Reincidencia")
    ElementoConCosto.create!(:etiqueta => "Antecedentes")
    ElementoConCosto.create!(:etiqueta => "Huellas")
    ElementoConCosto.create!(:etiqueta => "Alta Pcia Bs As")
    ElementoConCosto.create!(:etiqueta => "Renovacion Pcia Bs As")
    ElementoConCosto.create!(:etiqueta => "Ambiental")
    case RAILS_ENV
    when "sgc_production"
      ElementoConCosto.create!(:etiqueta => "Certf Med Caba")
    when "hunter_production"
      ElementoConCosto.create!(:etiqueta => "Certificacion Documentacion")
    when "ci5_production"
      ElementoConCosto.create!(:etiqueta => "Certf Med Caba")
    end
    ElementoConCosto.create!(:etiqueta => "Certf Med Bs As")
    ElementoConCosto.create!(:etiqueta => "Colegio Med Bs As")
    ElementoConCosto.create!(:etiqueta => "Certificado Analitico")
    ElementoConCosto.create!(:etiqueta => "Alta CABA")
    ElementoConCosto.create!(:etiqueta => "Renovacion CABA")
    if RAILS_ENV=="ci5_production"
      ElementoConCosto.create!(:etiqueta => "CLU")
      ElementoConCosto.create!(:etiqueta => "Anexo III Serv. Poligono")
      ElementoConCosto.create!(:etiqueta => "Portacion")
      ElementoConCosto.create!(:etiqueta => "Foto")
      ElementoConCosto.create!(:etiqueta => "Foto Cuerpo Entero")
    else
      ElementoConCosto.create!(:etiqueta => "For1")
      ElementoConCosto.create!(:etiqueta => "For2")
      ElementoConCosto.create!(:etiqueta => "For3")
      ElementoConCosto.create!(:etiqueta => "For4")
      ElementoConCosto.create!(:etiqueta => "For5")
    end
    ElementoConCosto.create!(:etiqueta => "For6")
    ElementoConCosto.create!(:etiqueta => "Anx 4")
    ElementoConCosto.create!(:etiqueta => "Fisico Anexo 3")
    if RAILS_ENV=="sgc_production" or RAILS_ENV=="hunter_production"
      ElementoConCosto.create!(:etiqueta => "Foto")
    end
    ElementoConCosto.create!(:etiqueta => "Foto Recibo Haber")
    ElementoConCosto.create!(:etiqueta => "Form Anexo 3 Idon Tiro / Port")
    ElementoConCosto.create!(:etiqueta => "Anexo 6 Idon Tiro CLU")
    ElementoFormula.create!(:etiqueta => "Total Suma Gastada", :formula => "$3+$4+$5+$6+$7+$8+$9+$10+$11+$12+$13+$14+$15+$16+$17+$18+$19+$20+$21+$22+$23+$24+$25+$26+$27+$28+$29+$30+$31+$32+$33")
    ElementoGestionTramites.create!(:etiqueta => "Gestion y Tramites")
    ElementoDescuentoRecursosHumanos.create!(:etiqueta => "Total a Descontar")
    ElementoConBandera.create!(:etiqueta => "Vestuario y Equipo")
    ElementoConBandera.create!(:etiqueta => "Calzado")
    ElementoSimple.create!(:etiqueta => "Saldo a descontar")
    ElementoSimple.create!(:etiqueta => "Descuento realizado")
    ElementoFormula.create!(:etiqueta => "Diferencia", :formula => "$39-$40")
    ElementoDescuentoLogistica.create!(:etiqueta => "Total a Descontar")
    (1..12).each { |m| ElementoCuota.create!(:mes => m, :ano => 2009) }
    Vigilador.all.each { |v|
      ElementoCuota.all.each {|e|
        o = Cuota.new(:vigilador => v, :elemento => e)
        o.save!
      }
      v.reload
      v.datos.each { |d|
        case d.elemento_id
        when 39
          d.write_attribute(:elemento_id, 42)
          d.save!
        when 41 # cuota 1 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 43 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 42 # cuota 2 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 44 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 43 # cuota 3 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 45 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 44 # cuota 4 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 46 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 45 # cuota 5 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 47 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 46 # cuota 6 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 48 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 47 # cuota 7 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 49 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 48 # cuota 8 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 50 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 49 # cuota 9 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 51 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 50 # cuota 10 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 52 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 51
          d.write_attribute(:elemento_id, 39)
          d.save!
        when 52
          d.write_attribute(:elemento_id, 40)
          d.save!
        when 53
          d.write_attribute(:elemento_id, 41)
          d.save!
        when 54 # cuota 1 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 43 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 55 # cuota 2 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 44 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 56 # cuota 3 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 45 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 57 # cuota 4 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 46 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 58 # cuota 5 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 47 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 59 # cuota 6 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 48 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 60 # cuota 7 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 49 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 61 # cuota 8 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 50 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 62 # cuota 9 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 51 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 63 # cuota 10 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 52 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 74 # cuota 11 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 53 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 75 # cuota 11 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 53 }.first
          cuota.logistica = d.costo
          cuota.save!
        when 77 # cuota 12 recursos humanos
          cuota = v.cuotas.select{ |c| c.elemento_id == 54 }.first
          cuota.recursos_humanos = d.costo
          cuota.save!
        when 78 # cuota 12 logistica
          cuota = v.cuotas.select{ |c| c.elemento_id == 54 }.first
          cuota.logistica = d.costo
          cuota.save!
        end
      }
    }
  end

  def self.down
  end
end
