# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  CKEDITOR.on 'instanceReady', (event) ->
    editor = event.editor;
    if editor.name.startsWith('survey_questions_attributes')
      editor.focus();

  question_type = $('#survey_survey_type').val()

  $('#questions').sortable({
    placeholder: "ui-state-highlight",
    start: (event, ui) ->
      $('.slide-up-or-down').slideUp()
    stop: (event, ui) ->
      for name of CKEDITOR.instances
        CKEDITOR.instances[name].destroy()
      CKEDITOR.replaceAll()
      $('.survey_questions_position').each((index, div) => $(div).children('input').each((i, ch) => $(ch).val(index + 1)))
  })

  $('.survey_questions_ban_own_answer').each (i, elem) ->
    toggleOwnAnswer(question_type, elem)

  $('body').delegate 'i.toggle-fa-question', 'click', ->
    slideToggleQuestion $(this)

  $ ->
  $('#survey_available_to_all').change(->
    $('#participants').toggle !@checked
    return
  ).change()

  $('#questions').on 'cocoon:after-insert', (e, insertedItem) ->
    $('.survey_questions_position').each((index, div) => $(div).children('input').each((i, ch) => $(ch).val(index + 1)))
    $('.checkbox > label > input[type=checkbox]').each (i, elem) ->
      if !$(this).closest('label').is(':has(".checkbox-material")')
        $(this).after '<span class=\'checkbox-material\'><span class=\'check\'></span></span>'
        toggleOwnAnswer(question_type, elem.closest('.checkbox'))
      return
    console.log insertedItem.children('.cke').attr('id')
    $('.fileinput-button span').click ->
      $(this).next().click()
    $('.fileinput-button input[type=file]').change ->
      _button = $(this).prev()
      if $(this).val() != ''
        _button.data('text', _button.text())
        _button.html($(this)[0].files[0].name)
      else
        _button.html(_button.data('text'))

  $('#questions') . on 'cocoon:after-remove', (e, item) ->
    $('.survey_questions_position').each((index, div) => $(div).children('input').each((i, ch) => $(ch).val(index + 1)))
    if $('.survey_question:visible').length == 0
      $('.btn-add-question').show()

  $('#survey_survey_type').on 'change', ->
    question_type = $(this).val()
    $('.survey_questions_ban_own_answer').each (i, elem) ->
      toggleOwnAnswer(question_type, elem)

slideToggleQuestion = (_this) ->
  _nested_field = _this.closest('.nested-fields')
  _nested_field.find('.slide-up-or-down').slideToggle 'slow'
  if _this.hasClass('fa-chevron-up')
#    _this.closest('.head-container').find('.question_title h4').append(_nested_field.find('.head-for-span input').val() || '');
    _this.removeClass 'fa-chevron-up'
    _this.addClass 'fa-chevron-down'
  else
#    _this.closest('.head-container').find('.question_title h4').empty();
    _this.removeClass 'fa-chevron-down'
    _this.addClass 'fa-chevron-up'

toggleOwnAnswer = (question_type, checbox) ->
  _checkbox = $(checbox).find('input')

  if question_type == 'complex'
#    if $('.survey_question').length > 0
#      $('.btn-add-question').hide()
    _checkbox.prop('checked', true)
    _checkbox.prop("disabled", true)
    $('.select_question_type').each (i, elem) ->
      $(elem).val('single').change()
    $('.survey_questions_question_type').each (i, elem) ->
      $(elem).hide()
  else
#    $('.btn-add-question').show()
    $('.survey_questions_question_type').each (i, elem) ->
      $(elem).show()
    _checkbox.prop('checked', false)
    _checkbox.prop("disabled", false)