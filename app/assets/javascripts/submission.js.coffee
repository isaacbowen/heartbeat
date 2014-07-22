class Submission
  constructor: ->
    @$node = $('.submission')
    @progressTotal = @$('.step:not(.submitting)').length
    @setListeners()
    @detectStep()

  $: (selector) ->
    if selector
      $(selector, @$node)
    else
      @$node

  step: 0

  nextStep: -> @setStep(@step + 1)
  prevStep: -> @setStep(@step - 1)

  setStep: (step, protectMe = false) ->
    step = Math.max(step, 0)
    step = Math.min(@progressTotal, step)

    # don't let folks skip to the spinner screen
    if protectMe
      step = Math.min(@progressTotal - 1, step)

    @step = step
    @setViewport(@step)
    @setProgress(@step)

  saveStep: (step) ->
    $step = @$('.step').eq(step)

    $inputs = $step.find(':input')
    $inputs = $inputs.add $step.next(':input:hidden') # catch id the submission metric id
    $inputs = $inputs.add @$(':input[name=authenticity_token], :input[name=_method]')

    # note, capybara doesn't like PATCH'ing with data
    $.post @$('form').attr('action'), $inputs.serialize()

  detectStep: ->
    lastCompletedStep = @$('.step:first').nextUntil('.step:not(:has(.metric.completed))', '.step').last()[0]
    lastMetricStep = @$('.step:has(.metric):last')[0]

    if lastCompletedStep and lastCompletedStep != lastMetricStep
      @$('.step').each (i, node) =>
        if node == lastCompletedStep
          @setStep(i+1)
          false

  setViewport: (step) ->
    $stepNode = @$('.step').eq(step)

    @$('.steps').animate(marginLeft: "-=#{$stepNode.position().left}")
    @$('.steps .metric .comments').not($stepNode.find('.comments')).slideUp('fast')

    if $stepNode.find('.comments :input').val()
      $stepNode.find('.comments').slideDown('fast')

  progress: 0
  progressTotal: null
  setProgress: (progress) ->
    @progress = progress
    @$('.progress .meter').animate(width: "#{(@progress) / @progressTotal * 100}%")

  setListeners: ->
    $(window).resize =>
      @$('.step').outerWidth @$().width()
    $(window).trigger('resize')

    @$('.tags :input').autosizeInput(space: 10)
    setTimeout (=> @$('.tags :input').addClass('autosized')), 1000

    @$('.action-next a').click => @nextStep()
    @$('.action-previous a').click => @prevStep()

    @$('form').change => @saveStep(@step)

    @$('form :submit').click (e) =>
      e.preventDefault()

      @nextStep()
      setTimeout((=> @$('form').submit()), 1000)

    @$('.action-comment a').click ->
      $comments = $(this).closest('.metric').find('.comments')
      if $comments.is(':visible')
        $(this).fadeTo('fast', 1)
      else
        $(this).fadeTo('fast', 0.5)

      $comments.slideToggle('fast')
  
    @$('.comments .public').tooltip(container: 'body', delay: {show: 200, hide: 100})

    @$('.progress').click (e) =>
      targetPercentage = (e.clientX - $(e.currentTarget).offset().left) / $(e.currentTarget).width()
      targetStep = Math.round(@progressTotal * targetPercentage)

      if targetStep == @step
        if @progressTotal * targetPercentage > @step
          @setStep(targetStep + 1, true)
        else if @progressTotal * targetPercentage < @step
          @setStep(targetStep - 1, true)
      else
        @setStep(targetStep, true)

    @$('.rating :radio').click ->
      $metric = $(this).closest('.metric')
      $metric.find('textarea').focus()

      if parseInt($(this).val()) == 1 or parseInt($(this).val()) == 4
        unless $metric.find('.comments').is(':visible')
          $metric.find('.action-comment a').click()

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
