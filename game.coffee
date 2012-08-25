class Stage
  constructor: ->
    @$stage = $("#stage")

  fadeIn: ($html, ms=500) =>
    $html.hide()
    @$stage.html($html)
    $html.fadeIn(1000)

class Game
  constructor: (@stage) ->
    @stage.fadeIn(tmpl("logo"))

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "arrow.png"], ->
    game = new Game(stage)
