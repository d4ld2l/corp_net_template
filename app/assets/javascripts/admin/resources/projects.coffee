$ ->
  $('#profile_projects').on('cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return
    $('.datepicker-uicker').each ->
      $(this).datetimepicker({
        format: 'DD.MM.YYYY',
        locale: 'ru',
        #date: $(this).data('value'),
        useCurrent: false
      })
  )