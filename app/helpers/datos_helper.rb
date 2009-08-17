module DatosHelper
  def render_dato(vigilador, dato, acceso)
    partial = nil
    class_editable = acceso.permiso_escritura?(current_user) ? "editable" : ""
    locals = { :dato => dato, :class_editable => class_editable }
    
    if dato.elemento.is_a? ElementoConCosto
      partial = "common/elemento_con_costo"
    end
    if dato.elemento.is_a? ElementoSimple
      partial = "common/elemento_simple"
    end
    if dato.elemento.is_a? ElementoFormula
      partial = "common/elemento_formula"
      locals.delete(:class_editable)
    end
    if dato.elemento.is_a? ElementoFecha
      partial = "common/elemento_fecha"
    end
    if dato.elemento.is_a? ElementoGestionTramites
      locals.store(:vigilador, vigilador)
      partial = "common/elemento_gestion_tramites"
    end

    flags = (dato.elemento.is_a? ElementoDescuentoRecursosHumanos) ? "rrhh" : "logistica"
    if dato.elemento.is_a? ElementoDescuento
      locals.store(:flags, flags)
      locals.store(:vigilador, vigilador)
      locals.delete(:dato)
      partial = "common/elemento_descuento"
    end

    if dato.elemento.is_a? ElementoCuota
      partial = "common/elemento_cuota"
      locals.store(:campo, acceso.campo)
    end
    if dato.elemento.is_a? ElementoConBandera
      partial = "common/elemento_con_bandera"
    end

    return render(:partial => partial, :locals => locals)
  end

  def get_css(acceso, dato=nil)
    css = ""
    grupo = acceso.grupo
    css << " #{grupo.parent_group.namespace}_#{grupo.id}"
    if dato and not dato.elemento.is_a? ElementoCuota
      css << " facturado" if dato.facturado?
    end
    css
  end
end
