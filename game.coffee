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

  # type: 0 = up, 1 = right, 2 = down, 3 = left
  addArrow: (type) =>
    color = ["red", "orange", "yellow", "pink"]
    arrowId = type #TODO make a unique id here
    @$stage.append tmpl("arrow", arrowId: arrowId)

    @R = Raphael("arrow-#{arrowId}", 75, 75)
    rect = @R.rect(0, 0, 75, 75).attr(fill: color[type])
    img = @R.image("images/arrow.png", 0, 0, 75, 75).attr(transform: "r#{90*type}")

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
