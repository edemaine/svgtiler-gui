sidebarScale = 2

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
  del.addEventListener 'click', -> removeMapping(mapping)
  if mapping.function?
    div.setAttribute 'title', 'function-defined mapping'
  else
    div.setAttribute 'title', 'symbols: ' +
      (formatKey(key) for key of mapping.map).join ', '
    addTile key for key of mapping.map
  id('key').style.visibility = 'visible'
  board?.update()

removeMapping = (mapping) ->
  index = mappings.maps.indexOf mapping
  return unless index > -1
  mappings.maps.splice(index, 1)
  id('mappings').removeChild id('mappings').children[index]
  # removeTile key for key of mapping.map
  id('key').style.visibility = if mappings.maps.length then 'visible' else 'hidden'
  board?.update()

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

  constructor: (height=Board.minSize, width=Board.minSize, @emptyTile=' ') ->
    @board = (@emptyTile for c in [0...width] for r in [0...height])
    @listeners = []
    @update()

  addListener: (func) -> @listeners.push func

  height: -> @board.length
  width: -> @board[0].length
  set: (r, c, key) -> @board[r][c] = key if @board[r]?[c]?
  get: (r, c) -> @board[r]?[c] ? @emptyTile

  resize: (dh, dw, dr, dc, skip) ->
    @board = for r in [0...@height() + dh]
      for c in [0...@width() + dw]
        continue if skip? and skip r, c
        oldR = r - (dr?(r, c) ? dr)
        oldC = c - (dc?(r, c) ? dc)
        @get oldR, oldC
    @update()

  addRow: (row, copy) ->
    console.log 'addRow', row
    @resize 1, 0,
      ((r, c) -> r > row), 0,              # dr, dc
      ((r, c) -> not copy and r == coord)  # skip
  addColumn: (col, copy) ->
    @resize 0, 1,
      0, ((r, c) -> c > col),              # dr, dc
      ((r, c) -> not copy and c == coord)  # skip
  removeRow: (row) ->
    @resize -1, 0,
      ((r, c) -> -(r >= row)), 0           # dr, dc
  removeColumn: (col) ->
    @resize 0, -1,
      0, ((r, c) -> -(c >= col))           # dr, dc

  emptyRow: (r) ->
    for cell in @board[r] when cell != emptyTile
      return false
    true
  emptyCol: (c) ->
    for row in @board when row[c] != emptyTile
      return false
    true

  autosize: ->
    TODO() # TODO: update this to use [r][c] instead of [x][y]
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
    d.data = (key for key in row for row in @board)
    d

  update: ->
    # @autosize()
    lis(this) for lis in @listeners

class BoardView
  @defaultScale: 2

  constructor: (@board, @boardDiv) ->
    @board.addListener(@redraw)
    @scale = BoardView.defaultScale
    @redraw()

  @addRowKey: '__add_row__'
  @addColKey: '__add_col__'
  @removeRowKey: '__remove_row__'
  @removeColKey: '__remove_col__'
  @emptySpecialKey: '__empty__'

  isSpecialKey: (key) -> /^__\w+__$/i.test key

  uiMappingFunc: (key) =>
    return unless @isSpecialKey key
    return '' if key == BoardView.emptySpecialKey
    isRow = key in [BoardView.addRowKey, BoardView.removeRowKey]
    isAdd = key in [BoardView.addRowKey, BoardView.addColKey]
    """
    <symbol viewBox='0 0 20 20' #{if isRow then 'height' else 'width'}='auto'>
      <rect width='12' height='12' x='4' y='4' rx='4' fill='#{if isAdd then 'green' else 'red'}' />
      <text class='fa' x='10' y='10' alignment-baseline='middle' text-anchor='middle' stroke='white'>
        #{if isAdd then '+' else '&#8722;'}
      </text>
    </symbol>
    """

  preprocessDrawing: (drawing) ->
    height = drawing.data.length
    width = drawing.data[0].length
    for row in drawing.data
      row.push BoardView.addRowKey
      row.push if height > 1 then BoardView.removeRowKey else BoardView.emptySpecialKey

    drawing.data.push(BoardView.addColKey for i in [0...width])
    if width > 1
      drawing.data.push(BoardView.removeColKey for i in [0...width])
    else
      drawing.data.push(BoardView.emptySpecialKey for i in [0...width])

    drawing.data[height].push(BoardView.emptySpecialKey, BoardView.emptySpecialKey)
    drawing.data[height+1].push(BoardView.emptySpecialKey, BoardView.emptySpecialKey)
    return

  postprocessSymbols: (svg) ->
    # Add bounding box to every non-special symbol
    for elt in svg.children when elt.tagName == 'symbol' and
                                 elt.viewBox? and
                                 not @isSpecialKey elt.id
      bbox = element 'rect', 'bbox', []
      # quite hacky, probably fails horribly when the symbol has overflow
      bbox.setAttribute 'x', elt.viewBox.baseVal.x
      bbox.setAttribute 'y', elt.viewBox.baseVal.y
      bbox.setAttribute 'width', elt.viewBox.baseVal.width
      bbox.setAttribute 'height', elt.viewBox.baseVal.height
      bbox.setAttribute 'fill', 'transparent'
      bbox.setAttribute 'stroke', 'black'
      bbox.setAttribute 'stroke-width', '0.1'
      elt.appendChild bbox

  redraw: =>
    drawing = @board.toDrawing()
    @preprocessDrawing drawing
    console.log drawing.data

    uiMapping = new svgtiler.Mapping()
    uiMapping.load(@uiMappingFunc)
    newMappings = new svgtiler.Mappings [uiMapping, mappings]

    svg = drawing.renderSVGDOM(newMappings).documentElement
    @boardDiv.removeChild @boardDiv.firstChild while @boardDiv.firstChild
    @boardDiv.appendChild(svg)

    svg.removeAttribute 'preserveAspectRatio'
    svg.setAttribute 'width', svg.getAttribute('width') * @scale
    svg.setAttribute 'height', svg.getAttribute('height') * @scale

    @postprocessSymbols(svg)

    # Hack to recalculate... something? I'm not really sure what this does...
    svg.outerHTML = svg.outerHTML
    svg = @boardDiv.firstChild

    # Add click listeners
    for elt in svg.children when elt.tagName == 'use'
      row = elt.getAttribute 'data-r'
      col = elt.getAttribute 'data-c'
      do (row, col) =>
        key = elt.getAttribute('xlink:href').slice(1)
        if 0 <= row < @board.height() and 0 <= col < @board.width()
          tryPaint = =>
            # console.log(row, col)
            if selectedTile? and @board.get(row, col) != selectedTile
              @board.set row, col, selectedTile
              @board.update()

          elt.addEventListener 'mousedown', tryPaint
          elt.addEventListener 'mousemove', (e) =>
            tryPaint() if e.buttons & 1 # lowest bit = left button
        else if key == BoardView.addRowKey
          elt.addEventListener 'click', => @board.addRow row, true
        else if key == BoardView.addColKey
          elt.addEventListener 'click', => @board.addColumn col, true
        else if key == BoardView.removeRowKey
          elt.addEventListener 'click', => @board.removeRow row
        else if key == BoardView.removeColKey
          elt.addEventListener 'click', => @board.removeColumn col

    return

window.onload = ->
  load 'default.txt', defaultMapping
  board = new Board(10, 10)
  boardView = new BoardView(board, id('board'))

  id('load').addEventListener 'click', ->
    id('file').click()
  id('file').addEventListener 'input', ->
    return unless id('file').files.length
    file = id('file').files[0]
    reader = new FileReader()
    reader.onload = -> load file.name, reader.result
    reader.readAsText file, encoding: svgtiler.Input.encoding
    id('file').value = null;
  id('keyForm').addEventListener 'submit', (e) ->
    e.preventDefault()
    addTile id('key').value
    id('key').value = ''
  id('save').addEventListener 'click', TODO
  id('border').addEventListener 'click', TODO

