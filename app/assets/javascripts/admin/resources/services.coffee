# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(document).on 'change', '.bid_representation_allowance_information_about_participant_other_participants_counterparty_responsible input[type=checkbox]', ->
    $(this).closest('#other_participants')
           .find('.bid_representation_allowance_information_about_participant_other_participants_counterparty_responsible input[type=checkbox]')
           .not(this).prop('checked', false)

  $(document).on 'change', '.bid_representation_allowance_information_about_participant_participants_responsible input[type=checkbox]', ->
    $(this).closest('#participants')
      .find('.bid_representation_allowance_information_about_participant_participants_responsible input[type=checkbox]')
      .not(this).prop('checked', false)


  $('#documents').on('cocoon:after-insert', (e, insertedItem) ->
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

  $('#notifications').on 'cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return

  $('body').delegate '.user_participants', 'change', ->
    _this = $(this)
    $.get(
      url: "#{gon.users_admin_url}/#{_this.val()}/show_user_position"
      dataType: 'json'
      success: (data) ->
        _this.closest('.nested-fields').find('.user_position').val(data.position_name)
    )
