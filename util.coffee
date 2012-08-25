window.p = (args...) ->
  console.log args... if window.location.hostname is "localhost"

window.tmpl = (selector, data = {}) ->
  _.template($(selector).html())(data)
