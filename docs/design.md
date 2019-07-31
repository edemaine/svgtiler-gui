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

Constraints:
* Restrict painting to this selection (and letter press Unrestrict button)
* Save these restriction patterns, or rely on selection saving
* Restrict certain symbols to certain patterns of cells:
  * Function (in symbol file?) deciding whether symbol is allowed in certain
    coordinates
  * GUI: make selection, then drag it to a symbol?
* Matching edge lengths?
* Column widths and row heights constrained?

Synchronization/files
* Literal Google Sheets view? (supporting multiple parallel editors)
* Synchronized through custom server (supporting multiple parallel editors)
* Git sync
* Overleaf sync
* Dropbox sync
* Coauthor sync
