$ ->
  $('#collapse_legal_info').on('cocoon:after-insert', ->
    $('#collapse_legal_info').find('.add_fields').remove()
  )

  $('#account_phones').on 'cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return
