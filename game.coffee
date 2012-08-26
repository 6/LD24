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
    color =["blue", "orange", "yellow", "pink"]
    @$stage.append tmpl("arrow", arrowId: @arrowId, top: (rotation * 80) + 20)

    arrowSelector = "arrow-#{@arrowId}"
    @arrowId += 1
    R = Raphael(arrowSelector, 75, 75)
    rect = R.rect(0, 0, 75, 75).attr(fill: color[rotation], opacity: 0)
    img = R.image("images/arrow.png", 0, 0, 75, 75).attr(transform: "r#{90*rotation}")

    {$arrow: $("##{arrowSelector}"), rimg: img, rrect: rect, rotation: rotation}

  removeArrow: (arrow, result) =>
    flashColor = ["red", "blue", arrow["rrect"].attr("fill")][result]
    originalColor = arrow['rrect'].attr('fill')
    arrow["rrect"].animate {fill:flashColor}, 150, =>
      arrow["rrect"].animate {fill: originalColor, opacity: 0}, 500, =>
        arrow["$arrow"].remove()

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
    # TODO arrow key event listeners
    @nextLevel()

  sceneEnding: =>
    @stage.fadeOut =>
      @stage.clear()
      p "TODO ending"

  nextLevel: =>
    @level ?= 0
    @level += 1
    @stopTickTock = false
    @arrows_queue = []
    @tickTock()

  evolution: (done_fn) =>
    #TODO based on @level
    #TODO "GET READY" message
    @setProgress(0)
    done_fn() #TODO after GET READY

  setProgress: (amount) =>
    @progress = amount
    @progress = Math.min(1.0, Math.max(0, @progress)) # between 0 and 1 (inclusive)
    #TODO animate progress bar based on @progress, and then call done_fn

  tickTock: =>
    return  if @stopTickTock
    arrow = @stage.addArrow(randomRange(0, 3))
    arrow["rrect"].animate {opacity: 1}, 400
    arrow["$arrow"].animate {right: '+=550'}, 1000, 'linear', =>
      arrow["$arrow"].animate {right: '+=100'}, 600, 'linear'
      @stage.removeArrow(arrow, ARROW_RESULT.FAIL)
    @arrows_queue.push(arrow)
    setTimeout(@tickTock, randomRange(200, 500))

  #TODO finish this method
  onArrowPress: (e) =>
    return  if @stopTickTock
    actualArrow = @arrow_queue.shift()
    #TODO show right/wrong color for actualArrow
    #TODO @setProgress(@progress + some amount based on right/wrong)

    if @progress >= 1.0
      @stopTickTock = true
      # TODO remove all arrows
      level += 1
      if level > 3 then @sceneEnding() else @evolution(@nextLevel)

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "click-uncache.png", "arrow.png", "instructions.png"], ->
    new Game(stage)
