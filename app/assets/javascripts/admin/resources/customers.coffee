$ ->
  $('#counterparts').on 'cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return
  $('#customer_contacts').on 'cocoon:after-insert', (e, insertedItem) ->
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
      return
    $('.add-messenger-phone-button').on 'click', (e) ->
      $lastField = $(this).parent().find('input:last-of-type').clone()
      $lastField.val("")
      $(".phones").append($lastField)

    $('.add-social-url-button').on 'click', (e) ->
      $lastField = $('.social_urls_field:last-of-type').clone()
      $lastField.val("")
      $(".customer_customer_contacts_social_urls:last-of-type").append($lastField)
