class Stage
  constructor: ->
    @$stage = $("#stage")

  fadeOut: (done_fn, ms=150) =>
    @$stage.children().fadeOut(ms)
    # prevent done cb from being called multiple times if many children
    setTimeout(done_fn, ms)

  fadeIn: ($html, append=false, ms=500, done_fn) =>
    $html.hide()
    if append
      @$stage.append($html)
    else
      @$stage.html($html)
    $html.fadeIn(ms, done_fn)

  click: (fadeOutEverything, done_fn) =>
    @fadeIn tmpl("click"), true, 250
    @$stage.bind "click.clicktocontinue", =>
      @$stage.unbind("click.clicktocontinue")
      if fadeOutEverything
        @fadeOut(done_fn)
      else
        done_fn()

  clear: => @$stage.html("")

  addArrow: (rotation) =>
    color =["red", "orange", "yellow", "pink"]
    @$stage.append tmpl("arrow", arrowId: @arrowId)

    arrowSelector = "arrow-#{@arrowId}"
    @arrowId += 1
    R = Raphael(arrowSelector, 75, 75)
    rect = R.rect(0, 0, 75, 75).attr(fill: color[rotation])
    img = R.image("images/arrow.png", 0, 0, 75, 75).attr(transform: "r#{90*rotation}")

    {arrowSelector: arrowSelector, rimg: img, rrect: rect, rotation: rotation}

class Game
  constructor: (@stage) ->
    @sceneGame() #TODO replace w sceneIntro

  sceneIntro: =>
    @stage.fadeIn tmpl("logo"), false, 1000, =>
      @stage.click true, =>
        @stage.fadeIn tmpl("instructions"), false, 100, =>
          @stage.click true, @sceneGame

  sceneGame: =>
    @stage.clear()
    @stage.addArrow(0)
    @stage.addArrow(1)
    @stage.addArrow(2)
    @stage.addArrow(3)

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "click-uncache.png", "arrow.png", "instructions.png"], ->
    new Game(stage)
