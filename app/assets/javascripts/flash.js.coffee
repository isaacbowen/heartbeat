$ ->
  $('.flash .close').click ->
    $(this).closest('.flash').fadeOut 100, ->
      if $('.flash:visible').length == 0
        $('.flashes').fadeOut(100)
