Drawing modes:
* Painting mode (like old GUI)
* Spreadsheet mode: selected cell, type your symbol, tab goes right, enter
  goes down, shift-enter/tab goes up/left
  * Typing autocompletion so easy to retype weird symbol names
* Copy/paste
* Selection
  * Rectangle: Different meaning in grid aligned (like spreadsheet) vs. in
    rendered form (intersect with rectangle)
  * Lasso to select arbitrary shape regions
  * Filling with constant?
  * Dragging corner as in Excel (but ideally any corner, and in 2D at once) to
    repeat a pattern
* "Parity"-based selection
  * Define x and y period for the drawing
  * Selecting any cell also selects all cells of the same x/y "parity"
  * Can multiselect to do useful patterns
  * Switching to selection mode converts to regular selection, so can tweak
    individual cells (but can no longer grow/shrink automatically)
* Save selections for future use
* Text-based selection/search
  * Regex
  * Prefix, substring, exact match?
* Select all cells with same text, or same width, or same (width, height), or
  same height, or ...?
* Paste from spreadsheet

Symbol table
* Convert copy buffer into "megasymbol" for inclusion in symbol list?
* Custom keyboard shortcuts
* Floatable to make it closer to you

Viewing modes:
* 1 or 2 or 4(?) panels, each configurable (like Rhino)
* Each panel can be configured according to following parameters:
  * Just text (source) vs. images (rendered) vs. text+images
  * Restricting to grid (ignoring weird tile sizes) vs. as-rendered tile sizes
  * With/without margins (most useful/default only for grid mode, make them
    proportional to width/height so that weird tile sizes "shrink in place" so
    remain grid-aligned if they were before)
  * Raw text editor (CodeMirror)
    * Enables an SVG Tiler version of CodePen.
    * This is especially useful for `.coffee`/`.js`/`.txt` files -- and as you
      edit the definitions, the symbols change live.
    * We could also support CSV/TSV editing of drawings, where each text-edit
      operation (e.g. insert `hi\thi`) translates into corresponding grid
      operations (append `hi` to this cell, shift these cells right,
      prepend `hi` to this cell).
* Possibly multiple (e.g. 2) panel sets, each of which shows a particular
  tab/sheet, so that you can easily look at multiple drawings at once.
  Imagining top-level rows correspond to panel sets, and columns within them
  correspond to panels of a common tab/sheet.

Constraints:
* Restrict painting to this selection (and letter press Unrestrict button)
* Save these restriction patterns, or rely on selection saving
* Restrict certain symbols to certain patterns of cells:
  * CoffeeScript/JavaScript definition of a symbol can throw an exception to
    indicate that this use of symbol is invalid (e.g. bad neighbors or bad
    parity etc.)
  * GUI: make selection, then drag it to a symbol?
* Matching edge lengths?
* Column widths and row heights constrained?

Synchronization/files
* Synchronized through custom server (supporting multiple parallel editors)
  * Use operational transforms so that multiple changesets can be merged.
  * In addition to changing individual cells, we have operations like
    "insert new column at *i*", "shift this row/column up/down from here".
* Literal Google Sheets view? (supporting multiple parallel editors)
* Coauthor sync --- or perhaps we should just iframe-embed an SVG Tiler server,
  so that Coauthor doesn't need to know about custom operational transforms
  specific to spreadsheets.
* Git sync
* Overleaf sync
* Dropbox sync
