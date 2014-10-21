Spreadsheet
===========

Loads data from a Google spreadsheet based on its key.

    module.exports.load = (key, cb) ->
      url = "https://spreadsheets.google.com/pub?key=#{key}&hl=en&output=html"
      
      $.getJSON(url).then (data) ->
        console.log data
        cb(data)