$(document).on 'contentchange', ->
  $('.result-metric .value').click ->
    $metric = $(this).closest('.result-metric')

    $metric.find('.value.active').removeClass('active')
    $(this).addClass('active')

    $metric.find('.sparkline-wrapper.active').removeClass('active')
    $metric.find(".sparkline-wrapper.#{$(this).data('sparkline-key')}").addClass('active')

$ ->
  # FIXME the affix threshhold is fixed, doesn't get recalculated on window resize
  $result_header = $('.result > header')
  $result_header.affix(offset: {top: $result_header.offset().top})

  $(window).on 'resize scroll', ->
    if $result_header.is('.affix')
      $result_header.css 'left',  $result_header.parent().parent().offset().left
      $result_header.css 'width', $result_header.parent().parent().outerWidth()
    else
      $result_header.css 'left',  0
      $result_header.css 'width', '100%'
