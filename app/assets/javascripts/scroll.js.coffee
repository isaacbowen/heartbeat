#= require jquery.smooth-scroll
#= require jquery.ba-bbq

$(document).on 'click', 'a[href*="#"]', (e) ->
  if @hash and @pathname is location.pathname
    $.bbq.pushState '#/' + @hash.slice(1)
    e.preventDefault()

$(document).ready ->
  $(window).bind 'hashchange', ->
    tgt = location.hash.replace(/^#\/?/,'')
    if document.getElementById(tgt)
      $.smoothScroll(scrollTarget: '#' + tgt)

  $(window).trigger('hashchange')
