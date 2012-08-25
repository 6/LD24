ROTATION =
  UP: 0
  RIGHT: 1
  DOWN: 2
  LEFT: 3

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
    # TODO arrow key event listeners
    @nextLevel()

  sceneEnding: =>
    @stage.fadeOut =>
      @stage.clear()
      p "TODO ending"

  nextLevel: =>
    @level ?= 0
    @level += 1
    @progress = 0.0
    @stopTickTock = false
    @arrows_queue = []
    @tickTock()

  evolution: (done_fn) =>
    #TODO based on @level
    #TODO "GET READY" message
    @updateProgressBar()
    done_fn()

  updateProgressBar: =>
    #TODO based on @progress

  tickTock: =>
    return  if @stopTickTock
    arrow = @stage.addArrow(randomRange(0, 3))
    #arrow.animate, done = fail
    @arrows_queue.push(arrow)
    #setTimeout(@tickTock, randomRange(50, 200))

  #TODO finish this method
  onArrowPress: (e) =>
    return  if @stopTickTock
    actualArrow = @arrow_queue.shift()
    #TODO show right/wrong color for actualArrow
    # progress += some amount based on right/wrong
    @progress = Math.max(0, @progress)

    if @progress >= 1.0
      @progress = 1.0
      @stopTickTock = true
      # TODO remove all arrows
      level += 1
      if level > 3 then @sceneEnding() else @evolution(@nextLevel)
    @updateProgressBar()

$ ->
  stage = new Stage()
  preloadImages ["logo.png", "click-uncache.png", "arrow.png", "instructions.png"], ->
    new Game(stage)
