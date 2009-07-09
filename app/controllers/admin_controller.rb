class AdminController < ApplicationController
  def modificar_porcentaje_gestion
    anterior_porcentaje = VariacionPorcentajeGestion.porcentaje_actual
    nuevo_porcentaje = params["porcentaje"].to_f

    VariacionPorcentajeGestion.set_porcentaje(params["porcentaje"].to_f)
    Log.log(current_user, :variacion_porcentaje_descuento, nil, nil, "De #{anterior_porcentaje} a #{nuevo_porcentaje}.")
    render :nothing => true
  end
end