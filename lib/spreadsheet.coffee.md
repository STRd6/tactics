Spreadsheet
===========

Loads data from a Google spreadsheet based on its key.

    module.exports.load = (key) ->
      url = "https://spreadsheets.google.com/pub?key=#{key}&hl=en&output=html"
      
      $.getJSON(url)