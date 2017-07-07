@show_msg = (mess) -> $.notify mess, "success"
@show_err = () -> $.notify "Exception occured !", "error"

@labeltoid = (str) ->
  str.replace(/\W/g,'_')
