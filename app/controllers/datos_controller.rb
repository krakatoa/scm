class DatosController < ApplicationController
  def update
    @dato = Dato.find(params[:id])
    @dato.update_attributes(params[:dato])
    @dato.save!
    Log.log(current_user, :modificacion_dato, @dato.vigilador, @dato)
    respond_to do |wants|
      wants.js { head :ok }
    end
  end

  def facturar
    @dato = Dato.find(params[:id])
    @dato.facturar!
    Log.log(current_user, :facturacion, @dato.vigilador, @dato)
    if request.xhr?
      render :nothing => true
    end
  end
end
