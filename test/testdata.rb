ITEM_DATA = [
  {name: "James", score: '12'},
  {name: "Bob", score: '33'},
]

TABLE_DATA = [
  ['name', 'score'],
  ['James', '12'],
  ['Bob', '33']
]

CSV_DATA = %{
"name","score"
"James","12"
"Bob","33"
}.strip


MULTI_SHEET_TABLE_DATA = {
  "sheet1" => [['name'], ['james'], ['bob']],
  "sheet2" => [['value'], ['21'], ['12']],
}

MULTI_SHEET_ITEM_DATA = {
  "sheet1" => [{name: "james"}, {name: "bob"}],
  "sheet2" => [{value: "21"}, {value: "12"}],
}
