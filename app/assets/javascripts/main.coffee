# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require_tree ./views
#= require notifyjs_rails
#= require bootstrap-datepicker/core
#= require bootstrap-datepicker/locales/bootstrap-datepicker.fr.js
#= require jquery.flot
#= require jquery.flot.resize
#= require jquery.flot.time
#= require jquery.flot.pie
#= require jquery.flot.threshold
#= require typeahead

@myajax = (id) ->
   if $(".datepicker").length > 0
      $(".datepicker").remove()
   form = $("#new_main").serializeObject()
   entree =
      id : $('#'+id+" td input[name=id]").val()
      date : $('#'+id+" td input[name=date]").val()
      lastdate : $('#'+id+" td input[name=date]").val()
      days : $('#'+id+" td input[name=days]").val()
      months : $('#'+id+" td input[name=months]").val()
      cpS_id : $('#'+id+" td select[name=cp_s]").val()
      cpD_id : $('#'+id+" td select[name=cp_d]").val()
      category_id : $('#'+id+" td select[name=cat]").val()
      com : $('#'+id+" td input[name=com]").val()
      moyen_id : $('#'+id+" td select[name=moy]").val()
      pr : $('#'+id+" td input[name=pr]").val()
      poS : $('#'+id+" td input[name=pt]").is(':checked')
      poD : $('#'+id+" td input[name=ptd]").is(':checked')
   $.ajax
      url: $("#new_main").attr("action")
      method: "POST"
      data:
        entry: entree
        main: form.main
        locale: form.locale
      dataType: "json"
   .done (data) ->
      show_msg data.mess
      load_table data
   .fail () -> show_err

@delentry = (id) ->
   form = $("#new_main").serializeObject()
   $.ajax
      url: $("#new_main").attr("action").replace /table/, "delete"
      method: "POST"
      data:
        id:$('#'+id+" [name=id]").val()
        main:form.main
        locale:form.locale
      dataType:"json"
   .done (data) ->
      show_msg data.mess
      load_table data
   .fail () -> show_err


@duploradd = (id) ->
  if id == "rwnew"
    myajax(id)
  else
    duplicate(id)

@duplicate = (id) ->
  names = ["date","cp_s", "cp_d", "cat", "com", "moy", "pr"]
  $('#rwnew [name='+name+']').val($('#'+id+" [name="+name+"]").val()) for name in names

@supporclear = (id) ->
  if id == "rwnew"
    clearline(id)
  else
    delentry id

@clearline = (id) ->
  names = ["date", "cp_d", "cat", "com", "moy", "pr"]
  $('#rwnew [name='+name+']').val(null) for name in names

@setToday = (input) ->
  $(input).val($.fn.datepicker.DPGlobal.formatDate(new Date, $(input).data().dateFormat, $('#locale').val()))
  $(input).trigger('blur')

# config of client side templating engine
#EJS.config
#  cache: false

# loading table and setting event handlers
@load_table = (data) ->
  $("#tooltip").hide()
  return load_image data if data.image
  html = JST['views/table'](data)
  $(".content").html html
  $(".up_but").css 'display', 'contents' if data.page > 1 and data.nbpage>1
  $(".home_but").css 'display', 'contents' if data.page > 1 and data.nbpage>1
  $(".dn_but").css 'display', 'contents' if data.page < data.nbpage
  $(".end_but").css 'display', 'contents' if data.page < data.nbpage
  $("#main_page").val data.page
  if $(".datepicker").length > 0
    $(".datepicker").remove()
  $ -> $("[data-change]").on 'change', "input[name!='date'], select", () ->
    mid = $(this).parents("tr")[0].id
    if mid != "rwnew" or $(this)[0].name=="pr"
      myajax(mid)
  $ -> $("[data-change]").on 'blur', "input[name='date']", () ->
    mid = $(this).parents("tr")[0].id
    if mid != "rwnew" and $(".datepicker").length==0
      myajax(mid)
  $ -> $("button[name='duploradd']").click -> duploradd($(this).parents("tr")[0].id)
  $ -> $("button[name='supporclear']").click -> supporclear($(this).parents("tr")[0].id)
  $ -> $("[data-dblclick]").dblclick ->
    $(this).val(-$(this).val())
    myajax($(this).parents("tr")[0].id)
  $ -> $("[data-settoday]").click -> setToday($(this).closest("div.input-group").find("input:first"))
  $ -> $(".up_but").click -> updnpage(-1)
  $ -> $(".dn_but").click -> updnpage(+1)
  $ -> $(".home_but").click -> homepage()
  $ -> $(".end_but").click -> endpage()
  $ -> $("#soldepointe").click ->
    sval = $(this).html()
    tod=new Date()
    fom=new Date(tod.getFullYear(), tod.getMonth(),1,12)
    clearline "rwnew"
    $("#rwnew td input[name=date]").val($.fn.datepicker.DPGlobal.formatDate(fom, $("#rwnew td input[name=date]").data().dateFormat, $('#locale').val()))
    $("#rwnew td select[name=cp_s]").val($("#main_cpS_ids").val())
    $("#rwnew td select[name=cp_d]").val(data.first_parent)
    $("#rwnew td input[name=pr]").val(-1*parseFloat(sval))
    $("#rwnew td input[name=com]").val("encours CB")
  comta = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('com'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: data.typeahead
  comta.initialize()
  $ -> $('[name="com"]').typeahead(null,
    displayKey: 'com',
    source: comta.ttAdapter()
  )
  #$ -> $('[type="date"]').datepicker
  #  autoclose:true
updnpage = (offs) ->
  noffs=offs
  noffs=10*noffs if (window.isdble==offs)
  setTimeout(
    () ->
      if window.isset
        updnpagehelp window.isdble
      window.isset=false
  , 200 )
  if window.isset
    updnpagehelp noffs
    window.isset=false
  else
    window.isset=true
  window.isdble=offs
updnpagehelp = (offs) ->
  $("#main_page").val(Math.max(parseInt($("#main_page").val(),10) + offs,1))
  $("#new_main").submit()
homepage = () -> 
  $("#main_page").val(1)
  $("#new_main").submit()
endpage = () -> 
  $("#main_page").val(0)
  $("#new_main").submit()


@load_image = (data) ->
  $(".content").html '<div class="myplot"/>'
  switch data.type
    when 2
      $.plot(
        $(".myplot"),
        [
          data:data.soldes,
          color: "rgb(30,100,20)",
          threshold:
            below: 0.0,
            color: "rgb(200,20,30)"
          ]
        xaxis:
          mode: "time",
          timeformat: data.locplot
      )
    when 3
      $.plot(
        $(".myplot"),
        data.camemb,
        grid:
          hoverable:true
        series:
          pie:
            show:true
            label:
              show:true
              radius:1/2
              formatter:(label,series) ->
                "<div id="+labeltoid(series.label)+">" + label + "<br/>" + Math.round(series.percent) + "%</div>"
              threshold:0.00
      )
      $(".myplot").bind "plothover", (evet, pos, item ) ->
        if item
          if item.seriesIndex!=window.showedindex
            $("#pieLabel"+window.showedindex).fadeOut(100)
          if $("#pieLabel"+item.seriesIndex).css('display')=='none'
            $("#pieLabel"+item.seriesIndex).fadeIn(200)
            window.showedindex=item.seriesIndex
    when 4
      $.plot(
        $(".myplot"),
        data.recap,
        grid:
          hoverable:true
        xaxis:
          mode: "time",
          timeformat: data.locplot,
          tickSize:[1, "month"]
      )
      $(".myplot").bind "plothover", (evet, pos, item ) ->
        if item
          ww = $("#tooltip").width()
          hh = $("#tooltip").height()
          offs= if item.datapoint[1]<0 then 11 else -15
          $("#tooltip").html(
              item.datapoint[1].toFixed(2)
            ).css(
              top:item.pageY-hh/2+offs
              left:item.pageX-ww/2
              color:item.series.color
            ).fadeIn(200)
        else
          $("#tooltip").hide

# below is handle of form
$(document).ready ->
  $("#new_main").on("ajax:success", (e, data, status, xhr) ->
    show_msg data.mess
    load_table data
  ).on "ajax:error", (e, xhr, status, error) ->
    show_err
  $("#pos_toggle").click () ->
    $(":first-child", this).removeClass 'glyphicon-question-sign'
    $(":first-child", this).removeClass 'glyphicon-ok-sign'
    $(":first-child", this).removeClass 'glyphicon-remove-sign'
    switch $("#main_poS").val()
      when 'x'
        $("#main_poS").val("_")
        $(":first-child", this).addClass 'glyphicon-remove-sign'
      when '_'
        $("#main_poS").val("?")
        $(":first-child", this).addClass 'glyphicon-question-sign'
      else
        $("#main_poS").val("x")
        $(":first-child", this).addClass 'glyphicon-ok-sign'
  $("#new_main [name^='main']").on("change", (e ) ->
     $("#new_main").submit()
  )
  $("#new_main").submit()
