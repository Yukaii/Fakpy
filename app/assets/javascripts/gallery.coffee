# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  imagesLoaded '#container', ->
    $container = $('#container')

    $container.isotope
      itemSelector: '.gallery-item'
      # layoutMode: 'fitRows'

  # fancybox
  $("a.gallery-image-link").fancybox
    transitionIn: 'elastic',
    transitionOut: 'elastic',
    speedIn: 600,
    speedOut: 200,
    overlayShow: false,
    # showNavArrows: false,
    closeBtn: false,
    arrows: false,
    # autoScale: true,
    helpers:
      buttons: {}
    afterShow: ->
      $('.fancybox-inner').append('<div class="action"><div class="disagree"/><div class="agree"/><div class="gallery-count"/></div>')

      click_action = ->
        src = $('.fancybox-image').attr('src')
        alike_count = $("a[href=\"#{src}\"]").parent('.gallery-item').attr('alike-count')
        message = ""
        if alike_count > 10
          message = "\n\n照騙啦！崩潰惹 Q_Q"
        else
          message = "\n\n快加賴！不過我也不知道ㄏㄏ"
        $('.gallery-count').html("谷歌指數" + alike_count+"!"+ message)

      $('.agree').click click_action
      $('.disagree').click click_action

