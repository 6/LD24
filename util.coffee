window.p = (args...) ->
  console.log args... if window.location.hostname is "localhost"

window.tmpl = (selector, data = {}) ->
  $(_.template($("#tmpl-#{selector}").html())(data))

#TODO
'''window.preloadImages = (images_urls, done_fn) ->
  done_fn()  if images_urls.length == 0
  image = new Image()
  image.onLoad = ->
    preloadImages(images_urls[1..], done_fn)
  image.src = images_urls[0]
    '''
