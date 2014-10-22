Spreadsheet
===========

Load data from a Google spreadsheet from a key.

    transformRows = (rows) ->
      rows.map (row) ->
        output = {}
        
        Object.keys(row).forEach (key) ->
          if (/gsx\$/).test(key)
            humanKeyName = key.replace("gsx$", "")
          
            if row[key]?.$t.length
              value = row[key]?.$t 
            else 
              value = undefined
            
            output[humanKeyName] = value
            
        output

    get = (url) ->
      $.ajax
        dataType: "jsonp"
        type: "GET"
        url: url

    module.exports.load = (key, cb) ->
      transformedSpreadsheets = {}
      listUrl = "//spreadsheets.google.com/feeds/worksheets/#{key}/public/values?alt=json"
     
      get(listUrl).then (listData) ->
        sheetPromises = listData.feed.entry.map (sheet) ->
          sheetUrlComponents = sheet.id.$t.split("/")
          sheetId = sheetUrlComponents[sheetUrlComponents.length - 1]        
          sheetUrl = "//spreadsheets.google.com/feeds/list/#{key}/#{sheetId}/public/values?alt=json"

          promise = get(sheetUrl)
          
          promise.then (sheetData) ->
            spaces = new RegExp(" ", "g")
            sheetTitle = sheetData.feed.title.$t.replace(spaces, "")
            
            transformedSpreadsheets[sheetTitle] = transformRows(sheetData.feed.entry)
            
          return promise
        
        $.when.apply($, sheetPromises).then ->
          cb(transformedSpreadsheets)
