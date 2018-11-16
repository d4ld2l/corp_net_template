$ ->
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
    multipleSeparator: ', '