$ -> $('[title]').each ->
  options = {
    container: 'body'
    delay: {show: 200, hide: 100}
  }

  for key, value of options
    if override = $(this).data(key)
      options[key] = override

  $(this).tooltip(options)
