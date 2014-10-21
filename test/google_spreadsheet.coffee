Spreadsheet = require "../lib/spreadsheet"

describe "Google Spreadsheet wrapper", ->
  it "loads spreadsheet from a given key", ->
    sheet = Spreadsheet.load "0ArtCBkZR37MmdFJqbjloVEp1OFZLWDJ6M29OcXQ1WkE"
    assert.ok(Object.keys(sheet) > 0)
