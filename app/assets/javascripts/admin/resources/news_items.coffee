$ ->
  $('#photo-fields').on('cocoon:after-insert', (e, insertedItem) ->
    $('.fileinput-button span').click ->
      $(this).next().click()
    $('.fileinput-button input[type=file]').change ->
      _button = $(this).prev()
      if $(this).val() != ''
        _button.data('text', _button.text())
        _button.html($(this)[0].files[0].name)
      else
        _button.html(_button.data('text'))
  )

  $('#send_comment_in_news').click ->
    window.location.href = window.location.href