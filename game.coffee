class Stage
  constructor: ->
    @$stage = $("#stage")

  fadeOut: (done_fn, ms=200) =>
    @$stage.children().fadeOut(ms, done_fn)

  fadeIn: ($html, ms=500) =>
    $html.hide()
    @$stage.html($html)
    $html.fadeIn(ms)

class Game
  constructor: (@stage) ->
    @stage.fadeIn(tmpl("logo"), 2000)

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "arrow.png"], ->
    game = new Game(stage)
