class VigiladoresController < ApplicationController
  before_filter :require_user
  before_filter :authorize
  before_filter :get_namespace_y_grupo
  before_filter :load_vigiladores

  require 'uri'
  require 'spreadsheet/excel'
  include Spreadsheet

  def index
    original_params = params
    @grupos = Grupo.parents.user_allowed(current_user)

    # TODO Refactorizar filtros ! :) JS tambien :)
    begin
      params[:search][:conditions][:fecha_ingreso_greater_than_or_equal_to] = format_desde(params[:search][:conditions][:fecha_ingreso_greater_than_or_equal_to])
    rescue
    end

    begin
      params[:search][:conditions][:fecha_ingreso_less_than_or_equal_to] = format_hasta(params[:search][:conditions][:fecha_ingreso_less_than_or_equal_to])
    rescue
    end

    begin
      params[:search][:conditions][:datos][:fecha_greater_than_or_equal_to] = format_desde(params[:search][:conditions][:datos][:fecha_greater_than_or_equal_to])
    rescue
    end

    begin
      params[:search][:conditions][:datos][:fecha_less_than_or_equal_to] = format_desde(params[:search][:conditions][:datos][:fecha_less_than_or_equal_to])
    rescue
    end

    # 0 => Fecha Ingreso
    # 1 => Fecha Baja
    # 2 => Apellido
    # 3 => Nombre
    # 4 => Legajo
    if params.has_key?(:search) and params[:search].has_key?(:conditions)
      unless params[:filtrar] == "0" # Legajo
        params[:search][:conditions].delete(:legajo_like) if params[:search][:conditions].has_key?(:nombre_like)
      end
      unless params[:filtrar] == "1" # Fecha Ingreso
        params[:search][:conditions].delete(:fecha_ingreso_greater_than_or_equal_to) if params[:search][:conditions].has_key?(:fecha_ingreso_greater_than_or_equal_to)
        params[:search][:conditions].delete(:fecha_ingreso_less_than_or_equal_to) if params[:search][:conditions].has_key?(:fecha_ingreso_less_than_or_equal_to)
      end
      unless params[:filtrar] == "2" # Fecha Baja
        if params[:search][:conditions].has_key? :datos
          params[:search][:conditions][:datos].delete(:fecha_greater_than_or_equal_to) if params[:search][:conditions][:datos].has_key?(:fecha_greater_than_or_equal_to)
          params[:search][:conditions][:datos].delete(:fecha_less_than_or_equal_to) if params[:search][:conditions][:datos].has_key?(:fecha_less_than_or_equal_to)
        end
      end
      unless params[:filtrar] == "3" # Apellido
        params[:search][:conditions].delete(:apellido_like) if params[:search][:conditions].has_key?(:apellido_like)
      end
      unless params[:filtrar] == "4" # Nombre
        params[:search][:conditions].delete(:nombre_like) if params[:search][:conditions].has_key?(:nombre_like)
      end
    end

    @search = Vigilador.new_search(params[:search])
    if @search.order_by.blank? and @search.order_as.blank?
      @search.order_by = [ :apellido ]
      @search.order_as = 'ASC'
    end
    @vigiladores = @search.all

    if request.xhr?
      render :update do |page|
        Vigilador.with_user_editando(current_user_session.user).each(&:desbloquear!)
        page[:'tab-set'].replace_html :partial => "menu", :locals => { :grupos => @grupos }
        page.replace "namespace", "<input type=\"hidden\" value=\"#{@namespace}\" name=\"namespace\" id=\"namespace\"/>"
        page.replace_html "vigiladores", :partial => "vigiladores"
        page.replace_html "xls_export", xls_export_link(:action => @namespace, :search => original_params[:search])
      end
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
          @grupo.children_groups.each{ |g|
            g.accesos.each {|a|
              e = a.elemento
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

            @grupo.children_groups.each do |g|
              g.accesos.each do |a|
                if a.elemento.is_a? ElementoCuota
                  dato = vigilador.cuotas.select{|d| d.elemento == a.elemento}[0]
                else
                  dato = vigilador.datos.select{|d| d.elemento == a.elemento}[0]
                end

                if dato.elemento.is_a? ElementoFecha
                  hoja_vigiladores.write(fila, columna, dato.fecha.to_s)
                elsif dato.elemento.is_a? ElementoCuota
                  hoja_vigiladores.write(fila, columna, dato.send(a.campo))
                else
                  hoja_vigiladores.write(fila, columna, dato.valor)
                end
                columna += 1
              end
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
    if request.xhr?
      render :nothing => true
    else
      redirect_to vigiladores_path
    end
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

    def get_namespace_y_grupo
      @namespace = get_namespace(params, request)
      @grupo = get_grupo(@namespace)
    end

    def get_grupo(namespace=nil)
      grupo = nil
      if namespace.is_a? String
        case namespace
        when "recursos_humanos"
          grupo = Grupo.all(:conditions => {:etiqueta => "RRHH", :parent_id => nil})[0]
        when "logistica"
          grupo = Grupo.all(:conditions => {:etiqueta => "Logistica", :parent_id => nil})[0]
        when "sueldos"
          grupo = Grupo.all(:conditions => {:etiqueta => "Sueldos", :parent_id => nil})[0]
        end
      end
      grupo ||= Grupo.all(:conditions => {:etiqueta => "Resumen", :parent_id => nil})[0]
      return grupo
    end

    def get_namespace(params, request)
      valid_namespaces = %w{resumen recursos_humanos logistica sueldos}
      namespace_field = params["namespace"] if params.has_key?("namespace") and not params["namespace"].blank? and valid_namespaces.include?(params["namespace"])
      request_action = params["action"] if params.has_key?("action") and not params["action"].blank? and valid_namespaces.include?(params["action"])
      referer_path = nil
      if request.referer
        referer_path = URI.parse(request.referer).path
        if referer_path
          referer_path.gsub!("pupisgc", "")
          referer_path.gsub!("pupihunter", "")
          referer_path.gsub!("pupici5", "")
        end
      end
      referer = referer_path.gsub("/", "") if referer_path
      referer = nil if (referer.blank? or not valid_namespaces.include?(referer))

      namespace = nil
      namespace ||= namespace_field if namespace_field
      namespace ||= request_action if request_action
      namespace ||= referer if referer
      namespace ||= "resumen"

      return namespace
    end
end
