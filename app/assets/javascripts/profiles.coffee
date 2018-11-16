$ ->
  $('.add-messenger-phone-button').on 'click', (e) ->
    $lastField = $(this).parent().find('input:last-of-type').clone()
    $lastField.val("")
    $(".phones").append($lastField)

  $('.add-social-url-button').on 'click', (e) ->
    $lastField = $('input[name="profile[social_urls][]"]:last-of-type').clone()
    $lastField.find('input').val("")
    $(".profile_social_urls").append($lastField)

  $('#contact_phones').on('cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return
    $('.add-messenger-phone-button').on 'click', (e) ->
      $lastField = $(this).parent().find('.phones input:last-of-type').clone()
      $lastField.val("")
      $(".phones").append($lastField)
  )
