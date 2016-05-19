# ActiveRecords
class DataListConverter

  self.register_converter(:records, :item_iterator) do |records, options|
    columns = options[:columns]
    lambda { |&block|
      records.find_each do |record|
        item = columns.map do |column|
          [column[0].to_sym, record.send(column[1])]
        end.to_h
        block.call(item)
      end
    }
  end

end
