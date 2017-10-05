# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  if $('body').is(":has('.panel-body .nav')")
    $('#communityTab li').on 'click', ->
      _status = $(this).find('a').attr('href')
      if _status == '#create_news'
        return

      $('#communityTabContent').find(_status).empty()
      $.get {
        url: location.href + '/news_index'
        data: { state: _status }
        success: ->
          tab_for_feed = $('#communityTabContent .active')
      }

    $('body').delegate '.edit_news', 'click', ->
      _tab = $('#communityTab li').last()
      $('#communityTab li').not(_tab).removeClass('active')
      _tab.addClass('active')
      $.get {
        url: location.href + '/render_form'
        data: { resource_id: Number($(this).attr('id')) }
      }

    current_page = 1
    THRESHOLD = 300
    $paginationElem = $('.pagination')
    $window = $(window)
    $document = $(document)
    paginationUrl = $paginationElem.attr('data-pagination-endpoint')
    pagesAmount = gon.news_count || $paginationElem.attr('data-pagination-news-count')

    $paginationElem.hide()
    isPaginating = false

    $window.on 'scroll', ->
      setTimeout (->
        if $('#communityTabContent .active, #communityOtherUserTabContent .active').prop('id') == 'create_news' || $('#communityTabContent .active, #communityOtherUserTabContent .active').prop('id') == undefined
          return
        if !isPaginating and current_page < pagesAmount and $window.scrollTop() > $document.height() - $window.height() - THRESHOLD
          isPaginating = true
          $paginationElem.show()
          current_page++
          $.ajax(
            url: paginationUrl,
            data: { state: "##{$('#communityTabContent .active, #communityOtherUserTabContent .active').prop('id')}", page: current_page, per_page: 3 }
          ).done (result) ->
            isPaginating = false
            return
        if current_page >= pagesAmount
          $paginationElem.hide()
        return
      ), 1000

