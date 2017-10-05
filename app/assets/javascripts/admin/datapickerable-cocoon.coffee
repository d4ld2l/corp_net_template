$ ->
  $('.datepickerable').on('cocoon:after-insert', (e, insertedItem) ->
    $('.datepicker-uicker').each ->
      $(this).datetimepicker({
        format: 'DD.MM.YYYY',
        locale: 'ru',
        date: $(this).data('value'),
        useCurrent: false
      })
  )