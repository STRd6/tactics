Spreadsheet
===========

Loads data from a Google spreadsheet based on its key.

    module.exports.load = (key, cb) ->
      url = "//spreadsheets.google.com/feeds/list/#{key}/od6/public/values?alt=json"
      
      $.ajax
        dataType: "jsonp"
        type: "GET"
        url: url
      .then(cb)
        