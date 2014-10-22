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

    module.exports.load = (key) ->
      listUrl = "//spreadsheets.google.com/feeds/worksheets/#{key}/public/values?alt=json"
     
      get(listUrl).then (listData) ->
        sheetPromises = listData.feed.entry.map (sheet) ->
          sheetUrlComponents = sheet.id.$t.split("/")
          sheetId = sheetUrlComponents[sheetUrlComponents.length - 1]        
          sheetUrl = "//spreadsheets.google.com/feeds/list/#{key}/#{sheetId}/public/values?alt=json"

          get(sheetUrl)
                    
        $.when.apply($, sheetPromises).then (sheetData...) ->
          (sheetData.map (d) -> d[0]).reduce (memo, sheet) ->
            spaces = new RegExp(" ", "g")
            sheetTitle = sheet.feed.title.$t.replace(spaces, "")
              
            memo[sheetTitle] = transformRows(sheet.feed.entry)
            
            memo
          , {}
