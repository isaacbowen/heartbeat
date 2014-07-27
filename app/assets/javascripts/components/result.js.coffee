$(document).on 'contentchange', ->
  $('.result-metric .value').click ->
    $metric = $(this).closest('.result-metric')

    $metric.find('.value.active').removeClass('active')
    $(this).addClass('active')

    $metric.find('.sparkline-wrapper.active').removeClass('active')
    $metric.find(".sparkline-wrapper.#{$(this).data('sparkline-key')}").addClass('active')
