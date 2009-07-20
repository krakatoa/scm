class CuotasController < ApplicationController
  before_filter :authorize_user
  before_filter :get_vigilador

  def index
    @cuotas = @vigilador.cuotas
  end

  def edit
    @cuota = Cuota.find(params[:id])
  end

  def update
    @cuota = Cuota.find(params[:id])
    if @cuota.update_attributes(params[:cuota])
      redirect_to vigilador_cuotas_path @vigilador
    else
      render :action => :edit
    end
  end

  private
    def authorize_user
      unless current_user.has_super_edit?
        deny_access
      end
    end

    def get_vigilador
      @vigilador = Vigilador.find(params[:vigilador_id])
    end
end
