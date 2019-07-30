sidebarScale = 2
mainScale = 2

defaultMapping = '''
- <symbol viewBox="0 0 20 10"><rect width="20" height="10" fill="purple"/></symbol>
| <symbol viewBox="0 0 10 20"><rect width="10" height="20" fill="purple"/></symbol>
+ <symbol viewBox="0 0 10 10"><rect width="10" height="10" fill="green"/></symbol>
X <symbol viewBox="-10 -10 20 20" width="auto" height="auto"><circle r="10" fill="red"/></symbol>
  <symbol viewBox="0 0 10 10" width="10" height="10"></symbol>
'''

mappings = new svgtiler.Mappings()
tiles = {}
selectedTile = null
board = null

svgtiler.Drawing.keepMargins = true

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
    addTile key for key of mapping.map
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
  del.addEventListener 'click', (e) ->
    removeTile(key)
    e.stopPropagation()
  tile.addEventListener 'click', ->
    tiles[selectedTile]?.classList.remove 'selected'
    this.classList.add 'selected'
    selectedTile = key
  id('tiles').appendChild tile

removeTile = (key) ->
  return unless key of tiles
  selectedTile = null if selectedTile == key
  tile = tiles[key]
  delete tiles[key]
  id('tiles').removeChild tile

class Board
  @minSize: 3

  constructor: (nx=Board.minSize, ny=Board.minSize, @emptyTile=' ') ->
    @board = (@emptyTile for y in [0...ny] for x in [0...nx])
    @redraw()

  nx: -> @board.length
  ny: -> @board[0].length
  set: (x, y, key) -> @board[x][y] = key
  get: (x, y) -> @board[x]?[y] ? @emptyTile

  resize: (dnx, dny, dx, dy, skip) ->
    nx = @nx() + dnx
    ny = @ny() + dny
    @init nx, ny, null
    @board = for x in [0...nx]
      for y in [0...ny]
        continue if skip? and skip x, y
        if typeof dx == 'function'
          xold = x - dx x, y
        else
          xold = x - dx
        if typeof dy == 'function'
          yold = y - dy x, y
        else
          yold = y - dy
        @get xold, yold
    @redraw()

  addRow: (coord, copy) ->
    @resize 0, 1, 0,
      ((x, y) -> y >= coord),              # dy
      ((x, y) -> not copy and y == coord)  # skip
  addColumn: (coord, copy) ->
    @resize 1, 0,
      ((x, y) -> x >= coord), 0,           # dx, dy
      ((x, y) -> not copy and x == coord)  # skip
  removeRow: (coord) ->
    @resize 0, -1, 0,
      ((x, y) -> -(y >= coord))            # dy
  removeColumn: (coord) ->
    @resize -1, 0,
      ((x, y) -> -(x >= coord)), 0         # dx, dy

  emptyX: (x) ->
    for cell in @board[x] when cell != emptyTile
      return false
    true
  emptyY: (y) ->
    for row in @board when row[y] != emptyTile
      return false
    true

  autosize: ->
    ## Left
    for x in [0...@nx()]
      break unless @emptyX x
    if x == 0  ## no blanks: grow
      @resize 1, 0, 1, 0
    else
      x -= 1  ## leave one blank on side
      x = Math.min x, @nx() - Board.minSize  ## size at least Board.minSize
      if x > 0
        @resize -x, 0, -x, 0
    ## Right
    for x in [@nx()-1..0]
      break unless @emptyX x
    if x == @nx()-1  ## no blanks: grow
      @resize 1, 0, 0, 0
    else
      x += 2  ## leave one blank
      x = Math.max x, Board.minSize  ## size at least Board.minSize
      if x < @nx()
        @resize x - @nx(), 0, 0, 0
    ## Top
    for y in [0...@ny()]
      break unless @emptyY y
    if y == 0  ## no blanks: grow
      @resize 0, 1, 0, 1
    else
      y -= 1  ## leave one blank on side
      y = Math.min y, @ny() - Board.minSize  ## size at least Board.minSize
      if y > 0
        @resize 0, -y, 0, -y
    ## Bottom
    for y in [@ny()-1..0]
      break unless @emptyY y
    if y == @ny()-1  ## no blanks: grow
      @resize 0, 1, 0, 0
    else
      y += 2  ## leave one blank
      y = Math.max y, Board.minSize  ## size at least Board.minSize
      if y < @ny()
        @resize 0, y - @ny(), 0, 0
  
  toDrawing: ->
    d = new svgtiler.Drawing()
    d.load @board
    d

  # TODO: Maybe separate view from the model because we want the same board
  #       to be displayed in several different panels
  redraw: ->
    drawing = @toDrawing()
    svg = drawing.renderSVGDOM(mappings).documentElement
    boardDiv = id('board')
    boardDiv.removeChild boardDiv.firstChild while boardDiv.firstChild
    boardDiv.appendChild(svg)

    svg.removeAttribute 'preserveAspectRatio'
    svg.setAttribute 'width', svg.getAttribute('width') * mainScale
    svg.setAttribute 'height', svg.getAttribute('height') * mainScale

    # Add bounding box to every symbol
    for elt in svg.children when elt.tagName == 'symbol' and elt.viewBox?
      # quite hacky, probably fails horribly when there is overflow
      bbox = element 'rect', 'bbox', []
      bbox.setAttribute 'x', elt.viewBox.baseVal.x
      bbox.setAttribute 'y', elt.viewBox.baseVal.y
      bbox.setAttribute 'width', elt.viewBox.baseVal.width
      bbox.setAttribute 'height', elt.viewBox.baseVal.height
      bbox.setAttribute 'fill', 'transparent'
      bbox.setAttribute 'stroke', 'black'
      bbox.setAttribute 'stroke-width', '0.1'
      elt.appendChild bbox

    # Hack to recalculate... something? I'm not really sure what this does...
    svg.outerHTML = svg.outerHTML
    svg = boardDiv.firstChild

    # Add click listeners
    for elt in svg.children when elt.tagName == 'use'
      row = elt.getAttribute('data-r')
      col = elt.getAttribute('data-c')
      do (row, col) =>
        elt.addEventListener 'click', () =>
          console.log(row, col)
          if selectedTile
            @set(row, col, selectedTile)
            @redraw()

    return

window.onload = ->
  load 'default.txt', defaultMapping
  board = new Board()
  # test board
  board.redraw()

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
