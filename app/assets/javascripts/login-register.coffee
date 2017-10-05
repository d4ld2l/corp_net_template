$ ->
  $(".btn_login").click openLoginModal
  $(".btn_register").click openRegisterModal
  $(".show_login").click showLoginForm
  $(".show_register").click showRegisterForm

  $("form#sign_up_user, form#sign_in_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      window.location.replace("/");
    else
      shakeModal(data.errors)


showRegisterForm =()->
  $('.loginBox').fadeOut 'fast', ->
    $('.registerBox').fadeIn 'fast'
    $('.login-footer').fadeOut 'fast', ->
      $('.register-footer').fadeIn 'fast'
      return
    $('.modal-title').html 'Зарегистрироваться'
    return
  $('.error').removeClass('alert alert-danger').html ''
  return

showLoginForm =()->
  $('#loginModal .registerBox').fadeOut 'fast', ->
    $('.loginBox').fadeIn 'fast'
    $('.register-footer').fadeOut 'fast', ->
      $('.login-footer').fadeIn 'fast'
      return
    $('.modal-title').html 'Вход'
    return
  $('.error').removeClass('alert alert-danger').html ''
  return

openLoginModal =()->
  showLoginForm()
  setTimeout (->
    $('#loginModal').modal 'show'
    return
  ), 230
  return

openRegisterModal =()->
  showRegisterForm()
  setTimeout (->
    $('#loginModal').modal 'show'
    return
  ), 230
  return

shakeModal =(errors) ->
  html_errors = ''
  if errors
    $.map errors, (value, index) ->
      html_errors += '<strong>'+index.toString()+'</strong>:</br>'+value.toString()+'</br>'
  else
    html_errors = 'Invalid email/password combination'
  $('#loginModal .modal-dialog').addClass 'shake'
  $('.error').addClass('alert alert-danger').html html_errors
  $('input[type="password"]').val('');
  setTimeout (->
    $('#loginModal .modal-dialog').removeClass 'shake'
    return
  ), 1000
  return
