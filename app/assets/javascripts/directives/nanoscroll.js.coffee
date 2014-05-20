@rating.directive 'smNanoscroll', () ->
  class Scroll
    init: (target, scope) ->
      @target = target
      @viewport = @target.find('.nn-viewport')
      @viewport_height = undefined
      @target.addClass 'nn-scroll'
      scope.$watch =>
        @update() if @viewport_height isnt @viewport.height()

    update: ->
      viewport = @viewport
      @viewport_height = @viewport.height()
      if viewport.height() > @target.height()
        @target.css {'height': @target.css('max-height')}
        scroll = @target.find('.nn-scrlbar')
        scroll.css {'height' : @target.height()*(@target.height()/viewport.height())}
        @bind viewport, scroll
        @target.addClass('actv').find('.nn-scrlbar').fadeIn()
      else
        @target.removeClass('actv').find('.nn-scrlbar').fadeOut()
        viewport.off('mousewheel')
      @scrollbar @target
      false

    scrollbar: (target) ->
      sliderElem = target.find('.nn-container')[0]
      thumbElem = target.find('.nn-scrlbar')[0]
      thumbElem.ondragstart = ->
        false
      thumbElem.onmousedown = (e) =>
        e = @cbEvent(e)
        thumbCoords = @getCoords(thumbElem)
        shiftX = e.pageX - thumbCoords.left
        shiftY = e.pageY - thumbCoords.top
        sliderCoords = @getCoords(sliderElem)
        target.find('.nn-container').addClass 'scroll'
        document.onmousemove = (e) =>
          e = @cbEvent(e)
          newTop = e.pageY - shiftY - sliderCoords.top
          newTop = 0  if newTop < 0
          bottom = sliderElem.offsetHeight - thumbElem.offsetHeight
          newTop = bottom if newTop > bottom
          thumbElem.style.top = newTop + "px"
          @drag @target
          return
        document.onmouseup = ->
          document.onmousemove = document.onmouseup = null
          target.find('.nn-container').removeClass 'scroll'
          return
        false

    cbEvent: (e) ->
      e = e or window.event
      if not e.pageX? and e.clientX?
        html = document.documentElement
        body = document.body
        e.pageX = e.clientX + (html and html.scrollLeft or body and body.scrollLeft or 0) - (html.clientLeft or 0)
        e.pageY = e.clientY + (html and html.scrollTop or body and body.scrollTop or 0) - (html.clientTop or 0)
      e.which = (if e.button & 1 then 1 else ((if e.button & 2 then 3 else ((if e.button & 4 then 2 else 0)))))  if not e.which and e.button
      e

    getCoords: (elem) ->
      box = elem.getBoundingClientRect()
      body = document.body
      docEl = document.documentElement
      scrollTop = window.pageYOffset or docEl.scrollTop or body.scrollTop
      scrollLeft = window.pageXOffset or docEl.scrollLeft or body.scrollLeft
      clientTop = docEl.clientTop or body.clientTop or 0
      clientLeft = docEl.clientLeft or body.clientLeft or 0
      top = box.top + scrollTop - clientTop
      left = box.left + scrollLeft - clientLeft
      top: Math.round(top)
      left: Math.round(left)

    drag: (target) ->
      viewport = target.find('.nn-viewport')
      scroll = target.find('.nn-scrlbar')
      viewport.css {'top' : parseInt(scroll.css('top'))*(target.height() - viewport.height())/(target.height() - scroll.height())}
      false

    bind: (viewport, scroll) ->
      offset = 0
      viewport.mousewheel (event) =>
        viewport.parent().addClass 'scroll'
        event.preventDefault()
        event.stopPropagation()
        if ((offset <= 0) and event.deltaY < 0) or ((@target.height() - viewport.height() <= offset) and event.deltaY > 0)
          offset = offset + event.deltaY
          offset = 0 if offset > - 10 and event.deltaY > 0
          offset = (@target.height() - viewport.height()) if offset < (@target.height() - viewport.height() + 10) and event.deltaY < 0
        viewport.css {'top' : offset}
        scroll.css {'top' : (@target.height() - scroll.height())*offset/(@target.height() - viewport.height())}
        clearTimeout $.data(@, "timer")
        $.data @, "timer", setTimeout ->
          viewport.parent().removeClass 'scroll'
        , 1000
      false

  scroll = Scroll

  {
    template: '<div class="nn-container"><div class="nn-viewport" ng-transclude></div><div class="nn-sbcont"><i class="nn-scrlbar"></i></div></div>',
    replace: false,
    transclude: true,
    scope: {}
    link: ($scope, $element) ->
      if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
        $('body').addClass 'mobile'
      else
        (new scroll).init $element, $scope
      false
  }
