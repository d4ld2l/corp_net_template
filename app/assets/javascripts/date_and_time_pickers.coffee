$ ->
  $('.datepicker-uicker').each ->
    $(this).datetimepicker({
      format: 'DD.MM.YYYY',
      locale: 'ru',
      date: $(this).data('value'),
      useCurrent: false,
      startDate: $(this).data('startDate')
    })

$ ->
  $('.datetimepicker-uicker').each ->
    $(this).datetimepicker({
      format: 'DD.MM.YYYY HH:mm Z',
      locale: 'ru',
      date: $(this).data('value'),
      useCurrent: false
    })