sidebarScale = 2

defaultMapping = '''
- <symbol viewBox="0 0 20 10"><rect width="20" height="10" fill="purple"/></symbol>
| <symbol viewBox="0 0 10 20"><rect width="10" height="20" fill="purple"/></symbol>
+ <symbol viewBox="0 0 10 10"><rect width="10" height="10" fill="green"/></symbol>
X <symbol viewBox="-10 -10 20 20" width="auto" height="auto"><circle r="10" fill="red"/></symbol>
  <symbol viewBox="-10 -10 20 20" width="auto" height="auto"></symbol>
'''

mappings = new svgtiler.Mappings()
tiles = {}
selectedTile = null

id = (i) -> document.getElementById i
text = (t) -> document.createTextNode t
element = (tag, className, children) ->
  el = document.createElement tag
  el.className = className if className?
  el.appendChild child for child in children if children?
  el
TODO = -> alert "Sorry, this feature isn't supported yet."

formatKey = (key) ->
  key.replace(/ /g, '␣') or '(empty)'

load = (filename, filedata) ->
  input = svgtiler.Input.recognize filename, filedata
  if input instanceof svgtiler.Mapping
    addMapping input

addMapping = (mapping) ->
  mappings.push mapping
  id('mappings').appendChild div = element 'div', 'mapping', [
    text mapping.filename + " "
    del = element 'i', 'fas fa-times delete'
  ]
  del.addEventListener 'click', TODO
  if mapping.function?
    div.setAttribute 'title', 'function-defined mapping'
  else
    div.setAttribute 'title', 'symbols: ' +
      (formatKey(key) for key of mapping.map).join ', '
  id('key').style.visibility = 'visible'

addTile = (key) ->
  return if key of tiles
  symbol = mappings.lookup(key) ? svgtiler.unrecognizedSymbol
  if symbol.use?
    symbol = symbol.use new svgtiler.Context [[symbol]], 0, 0
  symbolSvg = symbol.xml.documentElement.cloneNode true
  symbolSvg.setAttribute 'id', symbolId = 't' + symbol.id()
  svg = document.createElementNS svgtiler.SVGNS, 'svg'
  #svg.setAttribute 'xmlns:xlink', svgtiler.XLINKNS
  svg.setAttribute 'width', symbol.width * sidebarScale
  svg.setAttribute 'height', symbol.height * sidebarScale
  svg.appendChild symbolSvg
  svg.setAttributeNS svgtiler.SVGNS, 'viewBox',
    "0 0 #{symbol.viewBox[2]} #{symbol.viewBox[3]}"
  if symbolSvg.tagName == 'symbol'
    use = document.createElementNS svgtiler.SVGNS, 'use'
    use.setAttribute 'href', '#' + symbolId
    svg.appendChild use
  tiles[key] = tile = element 'div', 'tile', [
    element 'div', null, [
      element 'code', null, [text formatKey key]
      del = element 'i', 'fas fa-times delete'
    ]
    svg
  ]
  del.addEventListener 'click', -> removeTile(key)
  tile.addEventListener 'click', ->
    tiles[selectedTile]?.classList.remove 'selected'
    this.classList.add 'selected'
    selectedTile = key
  id('tiles').appendChild tile

removeTile = (key) ->
  return unless key of tiles
  selectedTile = null if selectedTile == key
  tile = tiles[key]
  id('tiles').removeChild tile

window.onload = ->
  load 'default.txt', defaultMapping
  id('load').addEventListener 'click', ->
    id('file').click()
  id('file').addEventListener 'input', ->
    return unless id('file').files.length
    file = id('file').files[0]
    reader = new FileReader()
    reader.onload = -> load file.name, reader.result
    reader.readAsText file, encoding: svgtiler.Input.encoding
  id('keyForm').addEventListener 'submit', (e) ->
    e.preventDefault()
    addTile id('key').value
    id('key').value = ''
  id('save').addEventListener 'click', TODO
  id('border').addEventListener 'click', TODO
