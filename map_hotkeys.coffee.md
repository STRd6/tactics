Map Hotkeys
===========

    Hotkeys = require "hotkeys"

    module.exports = (I={}, self=Core(I)) ->
      self.include Hotkeys

      self.addHotkey "1", ->
        addEventListener "message", (event) ->
          if event.source is pixelEditorWindow
            console.log event
        , false

        pixelEditorWindow = window.open "http://strd6.github.io/pixel-editor/?4", "", "width=640,height=480"

      return self
