module DatosHelper
  def render_dato(vigilador, dato)
    return render(:partial => "common/elemento_con_costo", :locals => { :dato => dato }) if dato.elemento.is_a? ElementoConCosto
    return render(:partial => "common/elemento_simple", :locals => { :dato => dato }) if dato.elemento.is_a? ElementoSimple
    return render(:partial => "common/elemento_formula", :locals => { :dato => dato }) if dato.elemento.is_a? ElementoFormula
    return render(:partial => "common/elemento_fecha", :locals => { :dato => dato }) if dato.elemento.is_a? ElementoFecha
    return render(:partial => "common/elemento_gestion_tramites", :locals => { :vigilador => vigilador, :dato => dato }) if dato.elemento.is_a? ElementoGestionTramites

    flags = (dato.elemento.is_a? ElementoDescuentoRecursosHumanos) ? "rrhh" : "logistica"
    return render(:partial => "common/elemento_descuento", :locals => { :vigilador => vigilador, :flags => flags }) if dato.elemento.is_a? ElementoDescuento

    return render(:partial => "common/elemento_cuota", :locals => { :dato => dato }) if dato.elemento.is_a? ElementoCuota
    return render(:partial => "common/elemento_con_bandera", :locals => {:dato => dato}) if dato.elemento.is_a? ElementoConBandera
  end

  def get_css(elemento, dato=nil)
    css = ""
    elemento.grupos.each{ |grupo| css << " #{grupo.parent_group.namespace}_#{grupo.id}" }
    if dato
      css << " facturado" if dato.facturado?
    end
    css
  end
end
