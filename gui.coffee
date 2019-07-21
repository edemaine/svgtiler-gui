mappings = new Mappings()

id = (i) -> document.getElementById i
text = (t) -> document.createTextNode t

tiles = {}

window.onload = ->
  id('load').addEventListener 'click', ->
    id('file').click()
  id('file').addEventListener 'input', ->
    return unless id('file').files.length
    file = id('file').files[0]
    reader = new FileReader()
    reader.onload = ->
      div = document.createElement 'div'
      div.appendChild text file.name + " "
      del = document.createElement 'i'
      del.className = 'fas fa-times delete'
      del.addEventListener 'click', ->
        #TODO
      div.appendChild del
      id('mappings').appendChild div
      id('key').style.visibility = 'visible'
      console.log reader.result
      svgtiler.Input.recognize file.name, reader.result
    reader.readAsText file, encoding: svgtiler.Input.encoding
  id('keyForm').addEventListener 'submit', (e) ->
    e.preventDefault()
    key = id('key').value
    return if key of tiles
    tiles[key] = tile = document.createElement 'div'
    tile.appendChild text key.replace(/ /g, '␣') or '(blank)'
    id('tiles').appendChild tile
