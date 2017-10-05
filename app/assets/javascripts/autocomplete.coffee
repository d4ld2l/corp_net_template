ready = undefined
ready = ->
  engine = new Bloodhound(
    datumTokenizer: (d) ->
      Bloodhound.tokenizers.whitespace d.title
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: "../#{gon.controller_name}/autocomplete?q=%QUERY"
      wildcard: '%QUERY')
  promise = engine.initialize()
  promise.done(->
    return
  ).fail ->
    return
  $('#quick-search').typeahead null,
    name: 'engine'
    displayKey: (if gon.controller_name == 'users_admin' then 'email' else 'name')
    source: engine.ttAdapter()
    templates:
      suggestion: (data) ->
        if gon.controller_name == 'users_admin'
          _href_part = "../profiles"
          _title_link = data.email
        else
          _href_part = gon.controller_name
          _title_link = data.name

        _path = _href_part + "/#{data.id}"

        if data.photo != undefined && data.photo.url.length
          _img = "<img src='#{data.photo.url}'>"
        else
          _img = "<img alt='Фото отсутствует'>"

        "<a href='#{_path}'>#{_img} #{_title_link} </a>"

  return

$(document).ready ready
$(document).on 'page:load', ready