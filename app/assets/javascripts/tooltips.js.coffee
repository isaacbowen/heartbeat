$(document).on 'contentchange', ->
  $('[title]').each ->
    options = {
      tooltip: true
      container: 'body'
      delay: {show: 200, hide: 100}
    }

    for key, value of options
      override = $(this).data(key)
      if override? and override isnt ''
        options[key] = override

    if options['tooltip'] isnt true
      options['delay'] = {show: 10000000000, hide: 100}

    $(this).tooltip(options)

$ -> $(document).trigger('contentchange')
