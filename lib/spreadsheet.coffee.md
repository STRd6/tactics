Spreadsheet
===========

Loads data from a Google spreadsheet based on its key.

    # TODO: metaprogram this to be more flexible
    # when transforming arbitrary sheets
    transformRows = (rows) ->
      rows.map (row) ->
        {
          name: row.gsx$name?.$t
          description: row.gsx$description?.$t
          targetType: row.gsx$targettype?.$t
          targetZone: row.gsx$targetzone?.$t
          targetRange: row.gsx$targetrange?.$t
          effectRadius: row.gsx$effectRadius?.$t
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
        