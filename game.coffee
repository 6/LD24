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

class Game
  constructor: (@stage) ->
    @sceneIntro()

  sceneIntro: =>
    @stage.fadeIn tmpl("logo"), false, 1500, =>
      @stage.click true, =>
        p "TODO next thing here"

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "click.png", "arrow.png"], ->
    new Game(stage)
