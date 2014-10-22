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

    get = (url) ->
      $.ajax
        dataType: "jsonp"
        type: "GET"
        url: url

    module.exports.load = (key, cb) ->
      transformedSpreadsheets = []
      listUrl = "//spreadsheets.google.com/feeds/worksheets/#{key}/public/values?alt=json"
     
      get(listUrl).then (listData) ->
        sheetPromises = listData.feed.entry.map (sheet) ->
          sheetUrlComponents = sheet.id.split("/")
          sheetId = worksheetUrlComponents[worksheetUrlComponents.length - 1]        
          sheetUrl = "//spreadsheets.google.com/feeds/list/#{key}/#{worksheetId}/public/values?alt=json"

          promise = get(sheetUrl)
          
          promise.then (sheetData) ->
            transformedSpreadsheets.push processSpreadsheet(sheetData)
            
          return promise
        
        $.when.apply($, sheetPromises).then ->
          cb(transformedSpreadsheets)
