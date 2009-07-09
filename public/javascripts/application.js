// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ajaxComplete(function() {
  bind_links();
  display_datos();
  $(".date").datepicker({ dateFormat: 'dd-mm-yy' });
});
function bind_links() {
  $("a.link-alta").unbind("click");
  $("a.link-alta").click(function() {
    var vigilador_id = get_first_id($(this).attr("href"));
    $("#alta_vigilador_"+vigilador_id+"").load($(this).attr("href").replace("edit", "alta"));
    return false;
  });
  $("a.link-edit").unbind("click");
  $("a.link-edit").click(function () {
    var vigilador_id = get_first_id($(this).attr("href"));

    $.getJSON($(this).attr("href"), function(json){
      if (json.editable) {
        jQuery.each($("#vigilador_"+vigilador_id+" label.editable"), function() {
          $(this).replaceWith("<input id="+$(this).attr("id")+" value=\""+$(this).text()+"\" style=\""+$(this).attr("style")+"\" name=\""+$(this).attr("name")+"\" class=\""+$(this).attr("class")+"\" />");
        });
        $("#link-new").hide();
        $(".link-edit").hide();
        $("#vigilador_"+vigilador_id+" .link-save").show();
        $("td.dato input.editable").change().blur(function (input) {
          if ($(this).attr("value")) {
            var dato_id = $(this).attr("id").split("_")[1];
            var campo = $(this).attr("id").split("_")[2];
            var valor = $(this).attr("value");

            if (typeof(AUTH_TOKEN) == "undefined") return;
            $.ajax({
              type: "PUT",
              url: "datos/"+dato_id,
              data: "authenticity_token=" + encodeURIComponent(AUTH_TOKEN)+"&dato["+campo+"]="+valor,
              dataType: "script"
            });
          }
        });
      } else {
        alert("Otro usuario esta modificando los datos de este vigilador.");
      }
    });
    return false;
  });
  $("a.link-save").unbind("click");
  $("a.link-save").click(function () {
    $(this).hide();
    var id = get_first_id($(this).attr("href"));

    // desbloquear vigilador
    if (typeof(AUTH_TOKEN) == "undefined") return;
    $.ajax({
      type: "POST",
      url: $(this).attr("href") + "/desbloquear",
      data: "authenticity_token=" + encodeURIComponent(AUTH_TOKEN),
      dataType: "script"
    });
    $("#vigilador_"+id).unbind("ajaxComplete");
    $("#vigilador_"+id).load($(this).attr("href")).ajaxComplete(function() {
      bind_links();
    });
    $("a.link-edit").show();
    $("#link-new").show();
    return false;
  });
  $(".link-no_ingreso").click(function () {
    id = $(this).attr("value");
    $("#vigilador_"+id).load($(this).attr("href"));
    return false;
  });
}
$("#vigiladores_table").ready(function() {
  display_datos();
  bind_links();
});
$("#tab-set").ready(function() {
  display_menu();
});
function display_menu() {
  $("#tab-set > div").hide();
  $("#tab-set > div").eq(0).show();

  $("ul.tabs a").click(function() {
    var namespace = get_namespace($(this).attr("href"));
    $("ul.tabs a.selected").removeClass('selected');
    $("#tab-set > div").hide();
    $("#"+namespace).fadeIn('slow');
    $(this).addClass('selected');
    return false;
  });
  $("ul.menuitem a").click(function() {
    var grupo = get_namespace_and_number($(this).attr("href"));
    $("ul.menuitem a.selected").removeClass("selected");
    $(".dato.selected").hide();
    $(".dato.selected").removeClass("selected");
    $(".dato."+grupo).addClass("selected");
    $(".dato.selected").show();
    $(this).addClass('selected');
    return false;
  });
}
function display_datos() {
  $(".dato").hide();
  if ($("ul.menuitem a.selected").length > 0) {
    var grupo = get_namespace_and_number($("ul.menuitem a.selected").attr("href"));
    $(".dato."+grupo+"").addClass("selected");
    $(".dato.selected").show();
  }
}
function get_first_id(url) {
  regexp = /\/\w+\/(\d+)/;
  return url.match(regexp)[1];
}
function get_namespace(url) {
  arr = url.split("/");
  var ind = arr.length - 1;
  while (arr[ind] == "") {
    ind--;
  };
  return arr[ind];
}
function get_namespace_and_number(url) {
  regexp = /\/(\w+\/\d+)/;
  return url.match(regexp)[1].replace("/", "_");
}
function popup_modificacion_porcentaje() {
  var valor = prompt('Ingrese nuevo porcentaje (solo valor numerico)');
  if (!isNaN(valor) && valor != null) {
    if (typeof(AUTH_TOKEN) == "undefined") return;
    $.ajax({
      type: "POST",
      url: "admin/modificar_porcentaje_gestion",
      data: "authenticity_token=" + encodeURIComponent(AUTH_TOKEN)+"&porcentaje="+valor,
      dataType: "script",
      async: false,
      success: function fn() {
        $("span#porcentaje_gestion_tramites").html(valor)
        return false;
      }
    });
  } else {
    if (valor != null) {
      alert("'" + valor + "' no es un porcentaje valido.");
    };
  }
}
