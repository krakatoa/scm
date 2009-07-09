require 'rubygems'
require 'fastercsv'
require 'chronic'
require 'roo'

DATA_DIR = "#{RAILS_ROOT}/db/data"
HOJAS = %w{ rrhh logistica }

namespace :db do
  namespace :vigiladores do
    desc 'Prepara los archivos XLS para parsear'
    task(:preparar_csv => :environment) do
      parse_xls_to_csv(EMPRESA)
    end

    desc 'Carga inicial de vigiladores.'
    task(:cargar_csv => :environment) do
      HOJAS.each do |nombre_hoja|
        flags = {}
        flags.store(EMPRESA.to_sym, true)
        flags.store(nombre_hoja.to_sym, true)

        #flags.store(:test, true) # TEST

        cant_vigiladores_creados = Vigilador.count
        ind_row = 1
        FasterCSV.foreach(File.expand_path(File.join(DATA_DIR, "#{EMPRESA}_#{nombre_hoja}.csv"))) do |row|
          unless ind_row == 1
            parse_row(row, ind_row, flags)
          end
          ind_row += 1

          if flags.has_key?(:test) and ind_row == 15
            break
          elsif flags.has_key?(:sgc) and ind_row > 322
            break
          elsif flags.has_key?(:ci5) and ind_row > 1083
            break
          elsif flags.has_key?(:hunter) and ind_row > 722
            break
          end
        end
        puts "Se crearon #{Vigilador.count - cant_vigiladores_creados + 1} vigiladores."
      end
    end
  end
end

def parse_row(row, actual_row, flags={})
  begin
    ind = 0

    legajo = row[ind].to_s
    ind += 1

    if row[ind].is_a? String
      apellido = row[ind].strip.titlecase
      ind += 1
    end

    if row[ind].is_a? String
      nombre = row[ind].strip.titlecase
      ind += 1
    end

    dni = row[ind].to_s.gsub(",", "")
    ind += 1

    ingreso = Chronic.parse(row[ind])
    if ingreso
      fecha_ingreso = ingreso
      tipo_ingreso = TipoIngreso.find_by_etiqueta("normal")
    else
      if row[ind].is_a? String
        ingreso = row[ind].downcase.gsub("\303\223", "o")
        if TipoIngreso.tipos_ingreso.include?(ingreso)
          fecha_ingreso = nil
          tipo_ingreso = TipoIngreso.find_by_etiqueta(ingreso.downcase)
        else
          fecha_ingreso = nil
          tipo_ingreso = nil
        end
      end
    end
    ind += 1

    v = Vigilador.find_by_dni(dni)
    if v.blank?
      v = Vigilador.create!(:legajo => legajo,
                            :apellido => apellido,
                            :nombre => nombre,
                            :dni => dni,
                            :fecha_ingreso => fecha_ingreso,
                            :tipo_ingreso => tipo_ingreso
                          )
    end

    # Baja
    baja = Chronic.parse(row[ind])
    if baja
      d = v.datos.select{|d| d.elemento == Elemento.find(1)}[0]
      unless d.fecha
        d.fecha = baja
        d.save!
      end
    end
    ind += 1

    # Fecha Curso
    fecha_curso = Chronic.parse(row[ind])
    if fecha_curso
      d = v.datos.select{|d| d.elemento == Elemento.find(2)}[0]
      unless d.fecha
        d.fecha = fecha_curso
        d.save!
      end
    end
    ind += 1

    # Curso CABA 60 Horas
    cargar_costo v, 3, row[ind]
    ind += 1

    # Curso PBA
    cargar_costo v, 4, row[ind]
    ind += 1

    # Doble Curso
    doble_curso = row[ind].to_f
    if doble_curso > 0
      d = v.datos.select{|d| d.elemento == Elemento.find(5)}[0]
      unless d.costo > 0
        d.costo = doble_curso
        d.save!
      end
    end
    ind += 1

    # Curso Renovacion CABA 35 Horas
    curso_renovacion = row[ind].to_f
    if curso_renovacion > 0
      d = v.datos.select{|d| d.elemento == Elemento.find(6)}[0]
      unless d.costo > 0
        d.costo = curso_renovacion
        d.save!
      end
    end
    ind += 1

    27.times{ |shift|
      if flags.has_key?(:rrhh)
        d = v.datos.select{|d| d.elemento == Elemento.find(7 + shift)}[0]
        d.fecha = Chronic.parse(row[ind])
        d.costo = row[ind+1].to_f
        d.save!
      end
      ind += 2
    }

    ### en ci5 hay una columna foto de mas
    if flags.has_key?(:ci5)
      if flags.has_key?(:rrhh)
        ind += 2
      end
    end

    # Total Suma Gastada se autogenera
    ind += 1 # =+******+= #

    # Gestion y Tramites
    v.aplicar_gestion_tramites! # el porcentaje esta en 15
    #d = v.datos.select{|d| d.elemento == Elemento.find(35)}[0]
    #d.costo = row[ind].to_f
    #d.save!

    ind += 1
    #Total a Descontar RRHH

    ind += 1
    # Vestuario y Equipo
    if flags.has_key?(:logistica)
      if row[ind]
        if row[ind].match(/^[Ss][Ii]$/)
          valor = nil
          bandera = true
        elsif row[ind].match(/^[Nn][Oo]$/)
          valor = nil
          bandera = false
        else
          valor = row[ind].to_f
          bandera = nil
        end
      else
        valor = 0
        bandera = nil
      end
      d = v.datos.select{|d| d.elemento == Elemento.find(37)}[0]
      d.costo = valor
      d.facturado = bandera
      d.save!
    end

    ind += 1
    # Calzado
    if flags.has_key?(:logistica)
      if row[ind]
        if row[ind].match(/^[Ss][Ii]$/)
          valor = nil
          bandera = true
        elsif row[ind].match(/^[Nn][Oo]$/)
          valor = nil
          bandera = false
        else
          valor = row[ind].to_f
          bandera = nil
        end
      else
        valor = 0
        bandera = nil
      end
      d = v.datos.select{|d| d.elemento == Elemento.find(38)}[0]
      d.costo = valor
      d.facturado = bandera
      d.save!
    end

    ind += 1
    # Total a Descontar Logistica
    ind += 1
    # Total General a Descontar
    ind += 1

    # Cuotas
    10.times{ |shift|
      if flags.has_key?(:rrhh)
        base_element = 54
      elsif flags.has_key?(:logistica)
        base_element = 41
      end
      cargar_costo v, base_element + shift, row[ind]
      ind += 1
    }
    
    if flags.has_key?(:rrhh)
      #cuota 11
      cargar_costo v, 74, row[ind]
      ind += 1

      #cuota 12
      cargar_costo v, 77, row[ind]
      ind += 1
    elsif flags.has_key?(:logistica)
      if flags.has_key?(:hunter)
        #cuota 11
        cargar_costo v, 74, row[ind]
        ind += 1
      else
        # Bajas: Saldo a descontar
        cargar_costo v, 51, row[ind]
      end
      ind += 1

      # Bajas: Descuento realizado
      cargar_costo v, 52, row[ind]
      ind += 1
    end
  rescue => e
    puts "Fallo la carga de Vigilador en linea #{actual_row}"
    puts e.message
  end
end

def cargar_costo(vigilador, id_elemento, costo)
  return if not costo
  costo = costo.to_f
  d = vigilador.datos.select{|d| d.elemento == Elemento.find(id_elemento)}[0]
  if d.costo == 0 and costo > 0
    d.costo = costo.to_f
    d.save!
  end
end

def parse_xls_to_csv(nombre_empresa="")
  return false if nombre_empresa.blank?
  puts "Cargando #{nombre_empresa}.xls."
  excel = Excel.new(File.expand_path(File.join(DATA_DIR, "#{nombre_empresa}.xls")))

  HOJAS.each do |nombre_hoja|
    ind_sheet = 0
    excel.default_sheet = excel.sheets[ind_sheet]
    until excel.default_sheet.downcase == nombre_hoja or ind_sheet == excel.sheets.size
      excel.default_sheet = excel.sheets[ind_sheet]
      ind_sheet += 1
    end

    puts "Preparando #{nombre_empresa}_#{nombre_hoja}.csv"
    excel.to_csv(File.join(DATA_DIR, "#{nombre_empresa}_#{nombre_hoja}.csv"))
  end
end
