Bit Array
=========

Experiment to store an array of 1-bit data and serialize back and forth from JSON. 

    {ceil} = Math

    n = 8

    masks = [
      0b00000001
      0b00000010
      0b00000100
      0b00001000
      0b00010000
      0b00100000
      0b01000000
      0b10000000
    ]

    inverseMasks = masks.map (mask) ->
      ~mask & 0xff

    module.exports = (sizeOrData) ->
      if typeof sizeOrData is "string"
        view = deserialize(sizeOrData)
      else
        buffer = new ArrayBuffer(ceil(sizeOrData/n))
        view = new Uint8Array(buffer)

      self = 
        get: (i) ->
          byteIndex = i >> 3
          offset = i % n

          return (view[byteIndex] & masks[offset]) >> offset

        set: (i, value) ->
          byteIndex = i >> 3
          offset = i % n

          view[byteIndex] = ((value << offset) & masks[offset]) | (view[byteIndex] & inverseMasks[offset])

          return self.get(i)

        toJSON: ->
          serialize(view)

    mimeType = "application/octet-binary"

    deserialize = (dataURL) ->
      dataString = dataURL.substring(dataURL.indexOf(';') + 1)

      binaryString = atob(dataString)
      length =  binaryString.length

      buffer = new ArrayBuffer length

      view = new Uint8Array(buffer)

      i = 0
      while i < length
        view[i] = binaryString.charCodeAt(i)
        i += 1

      return view

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
