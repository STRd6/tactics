Spreadsheet
===========

Loads data from a Google spreadsheet based on its key.

    # TODO: metaprogram this to be more flexible
    # when transforming arbitrary sheets
    transformRows = (rows) ->
      rows.forEach (row) ->
        {
          name: row.gsx$name
          description: row.gsx$description
          targetType: row.gsx$targettype
          targetZone: row.gsx$targetzone
          targetRange: row.gsx$targetrange
          effectRadius: row.gsx$effectRadius
        }    

    processSpreadsheet = (data) ->            
      return {
        name: data.feed.title.$t
        entries: transformRows(data.feed.entry)
      }

    module.exports.load = (key, cb) ->
      url = "//spreadsheets.google.com/feeds/list/#{key}/od6/public/values?alt=json"
      
      $.ajax
        dataType: "jsonp"
        type: "GET"
        url: url
      .then (data) ->

Transform our raw spreadsheet result into something more useful.
Pass the result into our callback

        cb(processSpreadsheet(data))
        