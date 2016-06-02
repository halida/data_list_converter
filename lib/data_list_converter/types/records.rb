# ActiveRecords
class DataListConverter

  # columns = [:table_column1, :table_column2, ...]
  # display = [:display_name1, :display_name2, ...]
  # convert(:records, :item_data, query: query, columns: columns, display: display)
  self.register_converter(:records, :item_iterator) do |input, options|
    query = self.parameter(input, :query, :input)
    columns = self.parameter(input, :columns, :input)
    display = input[:display] || columns

    lambda { |&block|
      query.pluck(*columns).each do |data|
        item = {}
        data.each_with_index do |d, i|
          item[display[i]] = d
        end
        block.call(item)
      end
    }
  end

end
