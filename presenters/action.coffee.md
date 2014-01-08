Action Presenter
================

A trash heap where we put all the code to make our haml nice.

    module.exports = (action, ui) ->
      classes: ->
        classes = ["active", "blank", "disabled", "last"].select (name) ->
          action[name]
        .join(" ")
      click: ->
        unless action.disabled
          action.perform()
          ui.actionPerformed()
      title: ->
        action.description || ""
      style: ->
        if action.disabledFor > 0
          "background-image: none"
        else
          "background-image: url(#{action.icon})"
      progressContainer: ->
        if action.disabledFor > 0
          display = "block"
        else
          display = "none"

        "display: #{display};"
      progress: ->
        "width: #{((action.cooldown - action.disabledFor) / action.cooldown) * 100}%;"