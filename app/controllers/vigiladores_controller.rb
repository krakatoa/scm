class VigiladoresController < ApplicationController
  before_filter :require_user
  before_filter :authorize
  before_filter :load_vigiladores

  require 'spreadsheet/excel'
  include Spreadsheet

  def index    
    @grupos = Grupo.user_allowed(current_user).select {|ge| ge.parent_id == nil}

    begin
      @search_fecha_ingreso_greater_than_or_equal_to = format_desde(params[:search][:conditions][:fecha_ingreso_greater_than_or_equal_to])
      params[:search][:conditions][:fecha_ingreso_greater_than_or_equal_to] = @search_fecha_ingreso_greater_than_or_equal_to
    rescue
    end

    begin
      @search_fecha_ingreso_less_than_or_equal_to = format_hasta(params[:search][:conditions][:fecha_ingreso_less_than_or_equal_to])
      params[:search][:conditions][:fecha_ingreso_less_than_or_equal_to] = @search_fecha_ingreso_less_than_or_equal_to
    rescue
    end

    # 0 => Fecha Ingreso
    # 1 => Apellido
    # 2 => Nombre
    if params.has_key?(:search) and params[:search].has_key?(:conditions)
      unless params[:filtrar] == "0" # Fecha Ingreso
        params[:search][:conditions].delete(:fecha_ingreso_greater_than_or_equal_to) if params[:search][:conditions].has_key?(:fecha_ingreso_greater_than_or_equal_to)
        params[:search][:conditions].delete(:fecha_ingreso_less_than_or_equal_to) if params[:search][:conditions].has_key?(:fecha_ingreso_less_than_or_equal_to)
      end
      unless params[:filtrar] == "1" # Apellido
        params[:search][:conditions].delete(:apellido_like) if params[:search][:conditions].has_key?(:apellido_like)
      end
      unless params[:filtrar] == "2" # Nombre
        params[:search][:conditions].delete(:nombre_like) if params[:search][:conditions].has_key?(:nombre_like)
      end
    end

    @search = Vigilador.new_search(params[:search])
    if @search.order_by.blank? and @search.order_as.blank?
      @search.order_by = [ :apellido ]
      @search.order_as = 'ASC'
    end
    @search.per_page = 5
    @vigiladores = @search.all

    if request.xhr?
      render :partial => "vigiladores/vigiladores"
    else
      respond_to do |wants|
        wants.html {
          Vigilador.with_user_editando(current_user_session.user).each(&:desbloquear!)
          render :template => "vigiladores/index"
        }
        wants.xls  {
          filename = "vigiladores-#{Time.now.strftime("%Y%m%d-%m%s")}.xls"
          workbook = Excel.new("#{RAILS_ROOT}/public/xls/#{filename}")
          hoja_vigiladores = workbook.add_worksheet("Vigiladores")

          headers = ['Legajo', 'Apellido', 'Nombre', 'DNI', 'Fecha Ingreso']
          Grupo.find_by_id(1).children_groups.each{|c|
            c.elementos.each {|e|
              headers << e.etiqueta
              if e.is_a? ElementoConCosto
                headers << "Costo"
              end
            }
          }
          columna = 0
          headers.each do |header|
            hoja_vigiladores.write(0, columna, header)
            columna += 1
          end

          fila = 1
          @vigiladores.each do |vigilador|
            hoja_vigiladores.write(fila,0,vigilador.legajo)
            hoja_vigiladores.write(fila,1,vigilador.apellido)
            hoja_vigiladores.write(fila,2,vigilador.nombre)
            hoja_vigiladores.write(fila,3,vigilador.dni)
            unless vigilador.no_ingreso?
              hoja_vigiladores.write(fila,4,vigilador.fecha_ingreso.to_s)
            else
              hoja_vigiladores.write(fila,4, vigilador.tipo_ingreso.etiqueta)
            end
            columna = 5
            vigilador.datos.each do |dato|
              if dato.elemento.is_a? ElementoFecha
                hoja_vigiladores.write(fila, columna, dato.fecha.to_s)
              else
                hoja_vigiladores.write(fila, columna, dato.valor)
              end
              columna += 1
            end
            fila += 1
          end
          workbook.close
          send_file "#{RAILS_ROOT}/public/xls/#{filename}"
        }
      end
    end
  end

  # TODO esto va?
  def resumen; index; end
  def logistica; index; end
  def recursos_humanos; index; end
  def sueldos; index; end

  def new
    @vigilador = Vigilador.new

    respond_to do |wants|
      wants.js {
        render :update do |page|
          page[".link-edit"].hide
          page['link-new'].hide
          page.insert_html :bottom, :vigiladores, render(:partial => "vigiladores/new")
        end
      }
    end
  end

  def create
    @vigilador = Vigilador.new(params[:vigilador])

    respond_to do |wants|
      if @vigilador.save
        Log.log(current_user, :creacion, @vigilador)
        wants.js {
          render :update do |page|
            page.insert_html :bottom, :vigiladores_table, render(:partial => "vigiladores/vigilador")
            page.remove :new_vigilador
            page['link-new'].show
            page[".link-edit"].show
          end
        }
      else
        wants.js {
          render :update do |page|
            @vigilador.errors.each do |error|
              page.alert("#{error[0].titleize} #{error[1]}.")
            end
          end
        }
      end
    end
  end

  def edit
    @vigilador = Vigilador.find(params[:id])
    editable = false
    if not @vigilador.editando?
      editable = true
      @vigilador.bloquear_user(current_user)
    end
    if request.xhr?
      render :json => { :editable => editable }.to_json
    end
  end

  def alta
    @vigilador = Vigilador.find(params[:id])

    if request.xhr?
      render :partial => "alta", :locals => { "vigilador" => @vigilador }
    end
  end

  def no_ingreso
    @vigilador = Vigilador.find(params[:id])
    @vigilador.no_ingreso!
    Log.log(current_user, :desercion, @vigilador)
    respond_to do |wants|
      wants.js {
        render :partial => "vigiladores/vigilador_content", :locals => {:vigilador => @vigilador}
      }
    end
  end

  def aplicar_gestion_tramites
    @vigilador = Vigilador.find(params[:id])
    @vigilador.aplicar_gestion_tramites!

    respond_to do |wants|
      wants.js {
        redirect_to vigiladores_url
      }
    end
  end

  def desbloquear
    @vigilador = Vigilador.find(params[:id])
    @vigilador.desbloquear!
    render :nothing => true
  end

  def update
    @vigilador = Vigilador.find(params[:id])
    if params.has_key?(:vigilador) and params[:vigilador].has_key?(:fecha_ingreso)
      params[:vigilador][:fecha_ingreso] = format_params_to_time(params[:vigilador][:fecha_ingreso])
      
      Log.log(current_user, :alta, @vigilador)
      @vigilador.tipo_ingreso = TipoIngreso.find_by_etiqueta("normal")
    end

    respond_to do |wants|
      if @vigilador.update_attributes(params[:vigilador])
        wants.html { redirect_to vigiladores_path }
        wants.js   { render :nothing => true }
      else
        flash[:notice] = 'El vigilador no se pudo dar de alta.'
        redirect_to vigiladores_path
      end
    end
  end

  def show
    @vigilador = Vigilador.find(params[:id])
    if request.xhr?
      render :partial => "vigiladores/vigilador_content", :locals => {:vigilador => @vigilador}
    end
  end

  def descontar_cuotas
    @vigilador = Vigilador.find(params[:id])

    total = params[:descuento][:total].to_i
    mes_inicial = params[:descuento][:month].to_i
    cant_cuotas = params[:descuento][:cuotas].to_i
    @vigilador.descontar_cuotas!(total, mes_inicial, params[:descuento][:flags], cant_cuotas)
    redirect_to vigiladores_path
  end

  private
    def authorize
      #unless current_user.is_a? LogisticaUser or current_user.is_a? ContabilidadUser or current_user.is_a? AdminUser
      #  deny_access
      #end
    end

    def load_vigiladores
      @vigiladores = Vigilador.all
    end

    def format_desde(params); format_params_to_time(params);     end
    def format_hasta(params); format_params_to_time(params, 11, 59, 59);  end
    def format_params_to_time(params, hora=0, minuto=0, segundo=0)
      Time.local(params[:year], params[:month], params[:day], hora, minuto, segundo)
    end
end