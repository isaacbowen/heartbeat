$ ->
  $('.submission-toggle').click ->
    $(this).hide()
    $('.submission-form').slideDown('fast')

  $metricList = $('<ul class="metrics-list"></ul>').insertBefore('.metrics.optional')
  $('.metrics.optional .metric').hide().each ->
    $name = $('<li></li>').text($('.metric-name', this).text()).appendTo($metricList)
    $name.click =>
      $(this).slideToggle('fast')
      $name.toggleClass('expanded')

    if $(this).is('.completed')
      $name.click()

  $('.submission-form .rating-option').click ->
    $(this).closest('.rating').add(this).addClass('rated')

  $('.submission-form .rating-bookend').click ->
    current_option = $(this).closest('.rating').find(':radio:checked').closest('.rating-option')

    if current_option.length
      next_option = (
        if $(this).is('.negative')
          current_option.prev('.rating-option')
        else
          current_option.next('.rating-option')
      )

      next_option.find(':radio').click()
    else
      if $(this).is('.negative')
        $(this).closest('.rating').find(':radio:first').click()
      else
        $(this).closest('.rating').find(':radio:last').click()

  $('.submission-form .comments-toggle').click ->
    $(this).hide()
    $(this).next('.comments-input').slideDown('fast')
