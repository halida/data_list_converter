# records
class DataListConverter
  self.register_converter(
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
end
