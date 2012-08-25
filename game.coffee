class Stage
  constructor: ->
    @$stage = $("#stage")

  fadeIn: ($html, ms=1500) =>
    $html.hide()
    @$stage.html($html)
    $html.fadeIn(ms)

class Game
  constructor: (@stage) ->
    @stage.fadeIn(tmpl("logo"))

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "arrow.png"], ->
    game = new Game(stage)
