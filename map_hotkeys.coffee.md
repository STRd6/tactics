Map Hotkeys
===========

    Hotkeys = require "hotkeys"

    module.exports = (I={}, self=Core(I)) ->
      self.include Hotkeys

      self.addHotkey "f2", ->
        console.log "wat"
        pixelEditorWindow = window.open "http://strd6.github.io/pixel-editor/"
        
        addEventListener "message", (event) ->
          if event.source is pixelEditorWindow
            console.log event
        , false

      return self
