# Data List Converter

Data List Converter is a tool for converting data between different formats.

Example:

```ruby
data = [{name: 'James', age: '22'}, {name: 'Bob', age: '33'}]
DataListConverter.convert(:item_data, :table_data, data)
# => [["name", "age"], ["James", "22"], ["Bob", "33"]] 

require 'data_list_converter/types/csv_file'
DataListConverter.convert(:item_data, :csv_file, data, csv_file: {filename: 'result.csv'})
DataListConverter.convert(:csv_file, :item_data, {filename: 'result.csv'}) == data

require 'data_list_converter/types/xls_file'
sheets_data = {sheet1: data, sheet2: data}
DataListConverter.convert(:multi_sheet_item_data, :xls_file, sheets_data, xls_file: {filename: 'result.xls'})
DataListConverter.convert(:xls_file, :multi_sheet_item_data, {filename: 'result.xls'}) == sheets_data
```

You can also add filter to this process:

```ruby
filters = [
  # filter with default options
  :limit,
  # filter with options
  {limit: {size: 2}},
  # multiple filters
  [{limit: {size: 12}},
   {count: {size: 4}}],
]
filters.map do |filter|
  data = [{name: "james"}] * 10
  DataListConverter.convert(:item_data, :table_data, data, table_iterator: {filter: filter})
end
```

Please read [the source code](https://github.com/halida/data_list_converter/blob/master/lib/data_list_converter/) for more information,
also you can check [test examples](https://github.com/halida/data_list_converter/blob/master/test/).

## Data Types

- **item_data** like: `[{name: 'James', age: '22'}, ...]`, keys should be symbol.
- **item_iterator** iterator for item_data, used like: iter.call{|item| out << item}
- **table_data** like: `[["name", "age"], ["James", "22"], ["Bob", "33"], ...]`
- **table_iterator** iterator for table_data
- **csv_file** file in csv format
- **xls_file** file in excel format, should install `spreadsheet` gem, and `require 'data_list_converter/types/xls_file'`
- **xlsx_file** file in excel xml format, should install `rubyXL` gem, and `require 'data_list_converter/types/xlsx_file'`
- **multi_sheet** Contains several data with sheets:
    - **multi_sheet_table_iterator**: like: `{sheet1: table_iterator1, sheet2: table_iterator2}`
    - **multi_sheet_table_data**: like: `{sheet1: [['name', 'age'], ...], sheet2: ...}`
    - **multi_sheet_item_iterator**: like: `{sheet1: item_iterator1, sheet2: item_iterator2}`
    - **multi_sheet_item_data**: like: `{sheet1: [{name: 'James', age: 32}], sheet2: ...}`
- **records** ActiveRecord records, usage: `DataListConverter.convert(:records, :item_data, Users.where(condition), item_iterator: {columns: [:name, :age]})`


## Filters

**item_iterator/table_iterator limit**: limit item_iterator result counts, usage: `DataListConverter.convert(:item_data, :table_data, item_data, item_iterator: {filter: {limit: {size: 2}}})`

**item_iterator count**: count item_iterator items, usage: `DataListConverter.convert(:xls_file, :item_data, {filename: 'result.xls'}, item_iterator: {filter: {count: {size: 10}}})`, it will print current item counts every `size`.

Please check more [test examples](https://github.com/halida/data_list_converter/blob/master/test/filters_test.rb)

## Extend

You can add your own data types and filters, example:

```ruby
DataListConverter.register_converter(:records, :item_iterator) do |records, options|
  columns = options[:columns]
  lambda { |&block|
    records.find_each do |record|
      item = columns.map do |column|
        [column.first.to_sym, record.send(column[1])]
      end.to_h
      block.call(item)
    end
  }
end

DataListConverter.register_filter(:item_iterator, :limit) do |proc, options|
  limit_size = options[:size] || 10
  lambda { |&block|
    limit = 0
    proc.call do |item|
      block.call(item)
      limit += 1
      break if limit >= limit_size
    end
  }
end
```


## Todo

- doc for helpers, records
