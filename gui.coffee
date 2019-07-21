mappings = new Mappings()

id = (i) -> document.getElementById i
text = (t) -> document.createTextNode t
element = (tag, className, children) ->
  el = document.createElement tag
  el.className = className if className?
  el.appendChild child for child in children if children?
  el
TODO = -> alert "Sorry, this feature isn't supported yet."

tiles = {}

addMapping = (filename, filedata) ->
  id('mappings').appendChild mapping = element 'div', 'mapping', [
    text filename + " "
    del = element 'i', 'fas fa-times delete'
  ]
  del.addEventListener 'click', TODO
  id('key').style.visibility = 'visible'
  svgtiler.Input.recognize filename, filedata

addTile = (key) ->
  return if key of tiles
  tiles[key] = tile = element 'div', 'tile', [
    element 'code', null, [text key.replace(/ /g, '␣') or '(blank)']
  ]
  id('tiles').appendChild tile

window.onload = ->
  id('load').addEventListener 'click', ->
    id('file').click()
  id('file').addEventListener 'input', ->
    return unless id('file').files.length
    file = id('file').files[0]
    reader = new FileReader()
    reader.onload = -> addMapping file.name, reader.result
    reader.readAsText file, encoding: svgtiler.Input.encoding
  id('keyForm').addEventListener 'submit', (e) ->
    e.preventDefault()
    addTile id('key').value
    id('key').value = ''
  id('save').addEventListener 'click', TODO
  id('border').addEventListener 'click', TODO
