Spreadsheet = require "../lib/spreadsheet"

describe "Google Spreadsheet wrapper", ->
  it "loads spreadsheet from a given key", ->
    Spreadsheet.load "0ArtCBkZR37MmdFJqbjloVEp1OFZLWDJ6M29OcXQ1WkE", (data) ->
      assert.ok(Object.keys(data) > 0)
