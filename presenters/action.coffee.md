Action Presenter
================

A trash heap where we put all the code to make our haml nice.

    module.exports = (action) ->
      classes: ->
        classes = ["active", "blank", "disabled", "last"].select (name) ->
          action[name]
        .join(" ")
      title: ->
        action.description || ""
      style: ->
        "background-image: url(#{action.icon})"
