# Data List Converter

Data List Converter is a tool to convert data between different formats.

Example:

```ruby
data = [{name: 'James', age: '22'}, {name: 'Bob', age: '33'}]
DataListConverter.convert(:item_data, :table_data, data)
# => [["name", "age"], ["James", "22"], ["Bob", "33"]] 
DataListConverter.convert(:item_data, :csv_file, data, csv_file: {filename: 'result.csv'})
DataListConverter.convert(:item_data, :xls_file, data, csv_file: {filename: 'result.csv'})

DataListConverter.convert(:csv_file, :item_data, {filename: 'result.csv'}) == data
```

You can also add filter to this process:

```ruby
filter = :limit
filter = {limit: {size: 2}}
filter = [{limit: {size: 12}}, {count: {size: 4}}]
convert(:item_iterator, :table_data, iter, table_iterator: {filter: filter})
```

Please read [the source code](https://github.com/halida/data_list_converter/blob/master/lib/data_list_converter.rb) for more information,
also you can check [test examples](https://github.com/halida/data_list_converter/blob/master/test/data_list_converter_test.rb).

## Data Types

- **item_data** like: `[{name: 'James', age: '22'}, ...]`
- **item_iterator** iterator for item_data, used like: iter.call{|item| out << item}
- **table_data** like: `[["name", "age"], ["James", "22"], ["Bob", "33"], ...]`
- **table_iterator** iterator for table_data
- **csv_file** file in csv format
- **xls_file** file in excel format
- **multi_sheet_data** like: `{'sheet1' => [columns, row, row, ...], 'sheet2' => [columns, row, row, ...]}`
- **multi_sheet_iterator** like: `{'sheet1' => table_iterator1, 'sheet2' => table_iterator2}`
- **records** ActiveRecord records, usage: `DataListConverter.convert(:records, :item_data, query, item_iterator: {columns: [:name, :age]})`


## Filters

**item_iterator/table_iterator limit**: limit item_iterator result counts, usage: `DataListConverter.convert(:item_data, :table_data, item_data, item_iterator: {filter: {limit: {size: 2}}})`

**item_iterator count**: count item_iterator items, usage: `DataListConverter.convert(:xls_file, :item_data, {filename: 'result.xls'}, item_iterator: {filter: {count: {size: 10}}})`, it will print current item counts every `size`.

## Extend

You can add your data types and filters, example:

```ruby
DataListConverter.register_converter(
  :records, :item_iterator, lambda { |records, options|
    columns = options[:columns]
    lambda { |&block|
      records.find_each do |record|
        item = columns.map do |column|
          [column.first.to_sym, record.send(column[1])]
        end.to_h
        block.call(item)
      end
    }
  })

DataListConverter.register_filter(
  :item_iterator, :limit, lambda { |proc, options|
    limit_size = options[:size] || 10
    lambda { |&block|
      limit = 0
      proc.call do |item|
        block.call(item)
        limit += 1
        break if limit >= limit_size
      end
    }
  })
```
