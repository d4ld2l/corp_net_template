$ ->
  $('.fileinput-button span').click ->
    $(this).next().click()
  $('.fileinput-button input[type=file]').change ->
    _button = $(this).prev()
    if $(this).val() != ''
      _button.data('text', _button.text())
      _button.html($(this)[0].files[0].name)
    else
      _button.html(_button.data('text'))
