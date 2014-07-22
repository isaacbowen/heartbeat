$(document).on 'click', 'form .input :checkbox', (e) ->
  $collection = $(this).closest('.input').find('.collection')
  $statebox   = $(this).closest('.input').find(':checkbox.statebox')

  if $(this)[0] == $statebox[0]
    $collection.find(':checkbox').prop('checked', $(this).prop('checked'))
  else
    if $collection.find(':checkbox:checked').length == $collection.find(':checkbox').length
      $statebox.prop('checked', true).prop('indeterminate', false)
    else
      $statebox.prop('checked', false).prop('indeterminate', !!$collection.find(':checkbox:checked').length)

$ ->
  $(':checkbox.statebox').each ->
    $collection = $(this).closest('.input').find('.collection')
    $(this).prop('indeterminate', !!$collection.find(':checkbox:checked').length)
