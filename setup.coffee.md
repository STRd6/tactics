Setup
=====

Set up our runtime styles and expose some stuff for debugging.

    # For debug purposes
    global.PACKAGE = PACKAGE
    global.require = require

    runtime = require("runtime")(PACKAGE)
    runtime.boot()
    runtime.applyStyleSheet(require('./style'))

    # Updating Application Cache and prompting for new version
    require "appcache"
