mappings = new Mappings()

id = (x) -> document.getElementById x

window.onload = ->
  id('load').addEventListener 'click', ->
    id('file').click()
  id('file').addEventListener 'input', ->
    return unless id('file').files.length
    file = id('file').files[0]
    reader = new FileReader()
    reader.onload = ->
      div = document.createElement 'div'
      div.innerText = file.name + " "
      del = document.createElement 'i'
      del.className = 'fas fa-times'
      div.appendChild del
      id('mappings').appendChild div
      id('key').style.visibility = 'visible'
      console.log reader.result
      svgtiler.Input.recognize file.name, reader.result
    reader.readAsText file, encoding: svgtiler.Input.encoding
