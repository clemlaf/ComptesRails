# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $("[data-paramc]").on 'change', "input", () ->
    mid = $(this).parents("tr")[0].id
    tabn=$(this).parents("table").attr("name")
    myparam =
      table: tabn
      id : $("#"+mid+" td input[name='id']").val()
      name : $("table[name='"+tabn+"'] #"+mid+" td input[name='name']").val()
      parent_id : $("table[name='"+tabn+"'] #"+mid+" td input[name='parent']").val()
    $.ajax
      url: "/param/update"
      method: "POST"
      data:
        param: myparam
      dataType: "json"
    .done (data) ->
      show_msg data.mess
      prependline(data.line, data.tabname) if data.isnew
    .fail () -> show_err
  $("[data-paramd]").on 'click', () ->
    mid = $(this).parents("tr")[0].id
    tabn=$(this).parents("table").attr("name")
    myparam =
      table: tabn
      id : $("#"+mid+" td input[name='id']").val()
      name: 'todel'
    $.ajax
      url: "/param/delete"
      method: "POST"
      data:
        param: myparam
      dataType: "json"
    .done (data) ->
      show_msg data.mess
      $("table[name='"+data.tabname+"'] #rw"+data.id+"").hide()
    .fail () -> show_err

@prependline = (cont,tabname) ->
  $("table[name='"+tabname+"'] tr[id='rwnew']").before(cont)
  $("table[name='"+tabname+"'] tr[id='rwnew'] td input[name='name']").val("")
