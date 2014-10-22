Spreadsheet
===========

Load data from a Google spreadsheet from a key.

    # TODO: metaprogram this to be more flexible
    # when transforming arbitrary sheets
    transformRows = (rows) ->
      rows.map (row) ->
        output = {}
        attrNames = []
        Object.keys(row).forEach (key) ->
          if (/gsx\$/).test(key)
            output[attrNames.push(key.slice(4))] = row[key]?$t 
            
        output

    processSpreadsheet = (data) ->
      output = {}      
      output[data.feed.title.$t] = transformRows(data.feed.entry)
      output

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
          sheetUrlComponents = sheet.id.$t.split("/")
          sheetId = sheetUrlComponents[sheetUrlComponents.length - 1]        
          sheetUrl = "//spreadsheets.google.com/feeds/list/#{key}/#{sheetId}/public/values?alt=json"

          promise = get(sheetUrl)
          
          promise.then (sheetData) ->
            transformedSpreadsheets.push processSpreadsheet(sheetData)
            
          return promise
        
        $.when.apply($, sheetPromises).then ->
          cb(transformedSpreadsheets)
