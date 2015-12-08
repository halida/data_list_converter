# item_data: [{name: 'xx', value: 12}, ...]
# table_data: [['name', 'value'], ['xx', '12'], ..]
# item_iterator and table_iterator are iterators which yield each row
class DataListConverter
  self.register_converter(
    :item_iterator, :table_iterator, lambda{ |proc, options|
      lambda { |&block|
        columns = nil
        proc.call do |item|
          unless columns
            columns = item.keys.map(&:to_sym)
            block.call(columns.map(&:to_s))
          end
          # item_iterator key can be symbol or string
          block.call(columns.map{ |c| item[c] || item[c.to_s] })
        end
      }
    })
  self.register_converter(
    :table_iterator, :item_iterator, lambda{ |proc, options|
      lambda {|&block|
        columns = nil
        proc.call do |row|
          unless columns
            columns = row.map(&:to_sym)
          else
            block.call(columns.zip(row).to_h)
          end
        end
      }
    })

  def self.iterator_to_data(proc, options={})
    out = []
    proc.call { |d| out << d }
    out
  end
  self.register_converter(
    :item_iterator, :item_data, self.method(:iterator_to_data))
  self.register_converter(
    :table_iterator, :table_data, self.method(:iterator_to_data))

  def self.data_to_iterator(data, options={})
    lambda { |&block|
      data.each do |d|
        block.call(d)
      end
    }
  end
  self.register_converter(
    :item_data, :item_iterator, self.method(:data_to_iterator))
  self.register_converter(
    :table_data, :table_iterator, self.method(:data_to_iterator))
end
