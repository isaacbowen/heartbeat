$ ->
  $('.result-metric .value').click ->
    $metric = $(this).closest('.result-metric')

    $metric.find('.value.active').removeClass('active')
    $(this).addClass('active')

    $metric.find('.sparkline.active').removeClass('active')
    $metric.find(".sparkline.#{$(this).data('sparkline-key')}").addClass('active')
