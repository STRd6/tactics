Spreadsheet = require "../lib/spreadsheet"

describe "Google Spreadsheet wrapper", ->
  it "loads spreadsheet from a given key", (done) ->
    Spreadsheet.load "0ArtCBkZR37MmdFJqbjloVEp1OFZLWDJ6M29OcXQ1WkE", (data) ->
      console.log data
      assert data.name is "Abilities"
      assert data.entries.length > 0
      done()