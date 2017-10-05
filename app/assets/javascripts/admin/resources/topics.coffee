# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('body').delegate 'button.reply', 'click', ->
    $("html, body").animate({ scrollTop: document.body.scrollHeight }, 1000);
    _id = $(this).attr("id")
    $('#parent_message_body').html("<a href='##{_id}'>Сообщение на которое Вы отвечаете</a>")
    $('#message_parent_message_id').val($(this).attr('id'))

  $('#parent_message_body').on 'click', ->
    _message = $('.panel-body').find($(this).find('a').attr('href')).closest('.row')
    _message.addClass('illumination')
    setTimeout (->
      _message.removeClass 'illumination'
      return
    ), 1000
    return
