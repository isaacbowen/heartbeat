$ ->
  $('.submission-toggle').click ->
    $(this).hide();
    $('.submission-form').slideDown('fast')

  $('.submission-form .comments-toggle').click ->
    $(this).hide();
    $(this).next('.comments-input').slideDown('fast')
