window.p = (args...) ->
  console.log args... if window.location.hostname is "localhost"

window.tmpl = (selector, data = {}) ->
  $(_.template($("#tmpl-#{selector}").html())(data))

#TODO parallel loading
window.preloadImages = (images_urls, done_fn, prefix="images/") ->
  return done_fn()  if images_urls.length == 0
  image = new Image()
  onloadHandler = -> preloadImages(images_urls[1..], done_fn)
  image.onload = onloadHandler
  image.onerror = -> alert("Error loading #{images_urls[0]}. Try refreshing")
  image.src = "#{prefix}#{images_urls[0]}"
  # if in cache, onload may not fire
  onloadHandler()  if image.complete

# inclusive
window.randomRange = (from, to) =>
  Math.floor(Math.random() * (to+1)) + from
