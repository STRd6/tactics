Binary
======

Experiment to store an array of 2-bit data and serialize back and forth from JSON. 

    {floor, ceil} = Math

    n = 8/2
    
    masks = [
      0b00000011
      0b00001100
      0b00110000
      0b11000000
    ]

    module.exports = (size) ->
      buffer = new ArrayBuffer(ceil(size/n))
      view = new Uint8Array(buffer)

      self = 
        get: (i) ->
          byteIndex = floor(i / n)
          offset = i % n
  
          return (view[byteIndex] & masks[offset]) >> (2 * offset)
  
        set: (i, value) ->
          byteIndex = floor(i / n)
          offset = i % n
  
          # TODO: this `|=` is cheating since we never erase
          view[byteIndex] |= (value << (2 * offset)) & masks[offset]
  
          return self.get(i)
  
        toJSON: ->
          serialize(view)

    mimeType = "application/octet-binary"

    deserialize = (dataURL) ->
      dataString = dataURL.substring(dataURL.indexOf(';'))

      binaryString = atob(dataString)

      buffer = new ArrayBuffer binaryString.length

      new Uint8Array(buffer)

    serialize = (bytes) ->
      binary = ''
      length = bytes.byteLength

      i = 0
      while i < length
        binary += String.fromCharCode(bytes[i])
        i += 1

      "data:#{mimeType};#{btoa(binary)}"

    serializeAsync = (buffer, cb) ->
      reader = new FileReader()

      reader.onloadend = ->
        cb reader.result

      reader.readAsDataURL new Blob [buffer],
        type: mimeType

      return
