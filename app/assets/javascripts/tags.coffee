$ ->
  if $('#resource_tag_list').length
    $('#resource_tag_list').val($('#resource_tag_list').val().replaceAll(' ', ', '))

$(document).ajaxSuccess ->
  if $('#resource_tag_list').length
    $('#resource_tag_list').val($('#resource_tag_list').val().replaceAll(' ', ', '))
