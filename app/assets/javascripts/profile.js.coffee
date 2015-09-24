checkStatus = ->
  $.get '/load_status', (data) ->
    if data == 'true'
      $('#repo-load-info').html "Repositories refreshed! Click <a href='/profile'>here</a> to reload."
    else
      $('#repo-alert').show()
      setTimeout checkStatus, 1000

$(document).ready ->
  if $('#repo-alert').length > 0
    checkStatus()