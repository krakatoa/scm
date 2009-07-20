class CuotasController < ApplicationController
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
    def get_vigilador
      @vigilador = Vigilador.find(params[:vigilador_id])
    end
end
