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
      transformedSpreadsheets = []
      listUrl = "//spreadsheets.google.com/feeds/worksheets/#{key}/public/values?alt=json"
     
      $.ajax
        dataType: "jsonp"
        type: "GET"
        url: listUrl
      .then (data) ->
        sheetPromises = data.feed.entry.map (sheet) ->
          sheetUrl = sheet.link[sheet.link.length - 1].href + "?alt=json"

          promise = $.ajax
            dataType: "jsonp"
            type: "GET"
            url: sheetUrl
        
          promise.then (data) ->
            transformedSpreadsheets.push processSpreadsheet(data)
            
          return promise
        
        $.when.apply($, sheetPromises).then ->
          cb(transformedSpreadsheets)
