# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$(document).ajaxComplete ->

  toggleInitialDestroy = (status, button) ->
    if status
      $(button).hide()
    else
      $(button).show()

  $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
    if !$(this).closest('label').is(':has(".checkbox-material")')
      $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
    return

  $('.initial_field:checked').each((i, elem) => (toggleInitialDestroy(true, $('#' + $(elem).attr('id').replace(/initial/, '_destroy')).siblings('.remove_bid_stage'))))

  $('#bid_stages').on 'cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return

  $(document).on 'change', '.initial_field', (e) ->
    toggleInitialDestroy($(this).prop('checked'), $('#' + $(this).attr('id').replace(/initial/, '_destroy')).siblings('.remove_bid_stage'))

  $('.allowed_bid_stages').on 'cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return

    $('.selectpicker').each ->
      val = $(this).data('label')
      $(this).selectpicker $.fn.selectpicker.defaults =
        liveSearchNormalize: true
        noneSelectedText: 'Ничего не выбрано'
        noneResultsText: 'Совпадений не найдено '
        countSelectedText: 'Выбрано {0} из {1}'
        maxOptionsText: [
          'Достигнут предел ({n} {var} максимум)'
          'Достигнут предел в группе ({n} {var} максимум)'
          [
            'items'
            'item'
          ]
        ]
        doneButtonText: 'Закрыть'
        multipleSeparator: ','

  $(document).on 'change', '.bid_stages_group_bid_stages_initial input[type=checkbox]', ->
    $(this).closest('#bid_stages')
      .find('.bid_stages_group_bid_stages_initial input[type=checkbox]')
      .not(this).each((i, x) => ($(x).prop('checked', false); toggleInitialDestroy(false, $('#' + $(x).attr('id').replace(/initial/, '_destroy')).siblings('.remove_bid_stage'))))

  $('.selectpicker').each ->
    val = $(this).data('label')
    $(this).selectpicker $.fn.selectpicker.defaults =
      liveSearchNormalize: true
      noneSelectedText: 'Ничего не выбрано'
      noneResultsText: 'Совпадений не найдено '
      countSelectedText: 'Выбрано {0} из {1}'
      maxOptionsText: [
        'Достигнут предел ({n} {var} максимум)'
        'Достигнут предел в группе ({n} {var} максимум)'
        [
          'items'
          'item'
        ]
      ]
      doneButtonText: 'Закрыть'
      multipleSeparator: ','