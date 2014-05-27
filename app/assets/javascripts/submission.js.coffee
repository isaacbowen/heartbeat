$ ->
  $('.submission-toggle').click ->
    $(this).hide();
    $('.submission-form').slideDown('fast')

  $('.submission-form .rating-option').click ->
    $(this).closest('.rating').add(this).addClass('rated')

  $('.submission-form .comments-toggle').click ->
    $(this).hide();
    $(this).next('.comments-input').slideDown('fast')
