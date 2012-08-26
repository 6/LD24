ROTATION =
  UP: 0
  RIGHT: 1
  DOWN: 2
  LEFT: 3

ARROW_RESULT =
  FAIL: 0
  SUCCESS: 1
  LEVELEND: 2

class Stage
  constructor: ->
    @$stage = $("#stage")
    @arrowId = 0
    @removedArrows = {}

  setGame: (game) => @game = game

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

  exclamation: (subtitle, text, ms, done_fn) =>
    selector = if subtitle? then "exclamation-with-subtitle" else "exclamation"
    @fadeIn if subtitle?
      tmpl(selector, {text: text, subtitle: subtitle})
    else
      tmpl(selector, {text: text})
    , true, ms/2, =>
      setTimeout =>
        $excl = $("##{selector}")
        $excl.fadeOut ms/2, =>
          $excl.remove()
          done_fn()
      , ms

  append: (html) =>
    @$stage.append(html)

  clear: => @$stage.html("")

  addArrow: (rotation) =>
    color =["grey", "orange", "yellow", "pink"]
    @$stage.append tmpl("arrow", arrowId: @arrowId, top: (rotation * 80) + 20)

    arrowSelector = "arrow-#{@arrowId}"
    @arrowId += 1
    R = Raphael(arrowSelector, 75, 75)
    rect = R.rect(0, 0, 75, 75).attr(fill: color[rotation], opacity: 0)
    img = R.image("images/arrow.png", 0, 0, 75, 75).attr(transform: "r#{90*rotation}")

    {$arrow: $("##{arrowSelector}"), rimg: img, rrect: rect, rotation: rotation}

  removeArrow: (arrow, result, fast=true) =>
    id = arrow["$arrow"].attr("id")
    return if @removedArrows[id]?
    @removedArrows[id] = true
    progressChange = 0.1 / @game.level
    progressChange *= -1  if result == ARROW_RESULT.FAIL
    @game.setProgress(@game.progress + progressChange) # less progress made the higher the level
    flashColor = ["red", "blue", arrow["rrect"].attr("fill")][result]
    originalColor = arrow['rrect'].attr('fill')
    flashSpeed = if fast then 100 else 150
    arrow["rrect"].animate {fill:flashColor}, flashSpeed, =>
      fadeSpeed = if fast then 150 else 500
      arrow["rrect"].animate {opacity: 0}, fadeSpeed, =>
        arrow["$arrow"].remove()

  removeAllArrows: (done_fn) =>
    @$stage.find(".arrow").fadeOut(250)
    setTimeout(done_fn, 250)

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
    @progress = 0
    @stage.append tmpl("progress-bar")
    $(document).keydown (e) =>
      pressed = {37: ROTATION.LEFT, 38: ROTATION.UP, 39: ROTATION.RIGHT, 40: ROTATION.DOWN}[e.keyCode]
      @onArrowPress(pressed)  if pressed?
    @nextLevel()

  sceneEnding: =>
    @stage.fadeOut =>
      @stage.clear()
      #TODO actual ending
      @stage.exclamation null, "END", 1400, =>
        p "DONE"

  nextLevel: =>
    @level ?= 1
    @stopTickTock = false
    @arrows_queue = []
    stage_s = if @level <= 2 then "Stage #{@level}" else "Final stage"
    @stage.exclamation stage_s, "Get ready", 1400, @tickTock

  evolution: (done_fn) =>
    @stage.exclamation "Evolution stage #{@level - 1}", "Complete", 1400, =>
      #TODO change char based on @level
      @setProgress(0)
      done_fn()

  setProgress: (amount) =>
    @progress = amount
    @progress = Math.min(1.0, Math.max(0, @progress)) # between 0 and 1 (inclusive)
    @progress = 0  if @progress < 0.001
    $bar = $("#stage").find("#progress-bar")
    $bar.find("#progress-bar-inner").animate({"width": "#{@progress * $bar.width()}px"}, 150)

  tickTock: =>
    return  if @stopTickTock
    arrow = @stage.addArrow(randomRange(0, 3))
    arrow["rrect"].animate {opacity: 1}, 250
    arrow["$arrow"].animate {right: '+=600'}, 1200, 'linear', =>
      @arrows_queue = _.reject @arrows_queue, (arr) =>
        arrow["$arrow"].attr("id") == arr["$arrow"].attr("id")
      arrow["$arrow"].animate {right: '+=100'}, 600, 'linear'
      @stage.removeArrow(arrow, ARROW_RESULT.FAIL, fast=false)
    @arrows_queue.push(arrow)
    setTimeout(@tickTock, randomRange(600, 800))

  onArrowPress: (pressed) =>
    return  if @stopTickTock
    actualArrow = @arrows_queue.shift()
    return  unless actualArrow?
    if actualArrow["rotation"] == pressed
      # correct arrow pressed
      @stage.removeArrow(actualArrow, ARROW_RESULT.SUCCESS)
    else
      # wrong arrow pressed
      @stage.removeArrow(actualArrow, ARROW_RESULT.FAIL)

    if @progress >= 0.99
      @setProgress(1)
      @stopTickTock = true
      @level += 1
      @stage.removeAllArrows =>
        if @level > 3 then @sceneEnding() else @evolution(@nextLevel)

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "click-uncache.png", "arrow.png", "instructions.png"], ->
    stage.setGame new Game(stage)
