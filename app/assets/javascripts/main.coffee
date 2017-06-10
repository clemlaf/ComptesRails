# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

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
   $.ajax
      url: "/main/table"
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
      url: "/main/delete"
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

@show_msg = (mess) -> $.notify mess, "success"
@show_err = () -> $.notify "Erreur !", "error"
@duploradd = (id) ->
  if id == "rwnew"
    ajax(id)
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
EJS.config
  cache: false

# loading table and setting event handlers
@load_table = (data) ->
  return load_image data if data.image
  html = new EJS
    url:'/templates/table.html.ejs'
  .render(data)
  $(".content").html html
  $("#up_row").css 'display', 'contents' if data.page > 1 and data.nbpage>1
  $("#dn_row").css 'display', 'contents' if data.page < data.nbpage
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
  $ -> $("#up_but").click ->
    $("#main_page").val($("#main_page").val() - 1)
  $ -> $("#dn_but").click ->
    $("#main_page").val($("#main_page").val() + 1)
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
        series:
          pie:
            show:true
      )
    when 4
      $.plot(
        $(".myplot"),
        data.recap,
        series:
          bars:
            show:true,
            barWidth:12*24*60*60*300
        xaxis:
          mode: "time",
          timeformat: data.locplot,
          tickSize:[1, "month"]
      )

# below is handle of form
$(document).ready ->
  $("#new_main").on("ajax:success", (e, data, status, xhr) ->
    show_msg data.mess
    load_table data
  ).on "ajax:error", (e, xhr, status, error) ->
    show_err
