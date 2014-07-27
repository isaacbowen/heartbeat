$ ->
  $nav = $('nav.main')
  $nav.affix(offset: {top: $nav.offset().top - 15})

  $(window).on 'resize scroll', ->
    if $nav.is('.affix')
      $nav.css 'left',  $nav.parent().offset().left
      $nav.css 'width', $nav.parent().outerWidth()
    else
      $nav.css 'width', 'auto'
