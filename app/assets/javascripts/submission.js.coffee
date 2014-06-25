class Submission
  constructor: ->
    @$node = $('.submission')
    @progressTotal = @$('.step:not(.submitting)').length
    @setListeners()

  $: (selector) ->
    if selector
      $(selector, @$node)
    else
      @$node

  step: 1

  nextStep: -> @setStep(@step + 1)
  prevStep: -> @setStep(@step - 1)

  setStep: (step) ->
    @step = step
    @setViewport(@step)
    @setProgress(@step)

  setViewport: (step) ->
    $stepNode = @$('.step').eq(step - 1)

    if $stepNode[0]
      @$().removeClass('summary').addClass('spotlight')
      @$('.steps').animate(marginLeft: "-=#{$stepNode.position().left}")
      @$('.steps .metric .comments').not($stepNode.find('.comments')).slideUp('fast')
      $('.container').removeClass('fullscreen')

      if $stepNode.find('.comments :input').val()
        $stepNode.find('.comments').slideDown('fast')

    else
      @$().removeClass('spotlight').addClass('summary')
      @$('.steps').removeAttr('style')
      $('.container').addClass('fullscreen')

  progress: 0
  progressTotal: null
  setProgress: (progress) ->
    @progress = progress
    @$('.progress .meter').animate(width: "#{(@progress - 1) / @progressTotal * 100}%")

  setListeners: ->
    @$('.action-next').click => @nextStep()
    @$('.action-previous').click => @prevStep()

    @$('form').submit (e) => @nextStep()

    @$('.action-comment').click ->
      $comments = $(this).closest('.metric').find('.comments')
      if $comments.is(':visible')
        $(this).fadeTo('fast', 1)
      else
        $(this).fadeTo('fast', 0.5)

      $comments.slideToggle('fast')
  
    @$('.comments .public').tooltip(container: 'body', delay: {show: 200, hide: 100})

    @$('.rating :radio').change ->
      $metric = $(this).closest('.metric')
      $metric.find('.rating-value').text($(this).val())
      $metric.find('textarea').focus()

      if parseInt($(this).val()) <= 2
        unless $metric.find('.comments').is(':visible')
          $metric.find('.action-comment').click()

    @$('.rating-option').click ->
      $(this).closest('.rating').add(this).addClass('rated')
      $(this).closest('.metric').addClass('completed')

    @$('.previous-rating-marker').click (e) ->
      e.preventDefault();
      e.stopPropagation();

    @$('.rating-bookend').click ->
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

$ -> heartbeat.submission = new Submission()
