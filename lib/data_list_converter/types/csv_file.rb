require 'csv'

# csv_file
class DataListConverter
  self.register_converter(
    :csv_file, :table_iterator, lambda { |input, options|
      lambda { |&block|
        CSV.open(input[:filename]) do |csv|
          csv.each do |row|
            block.call(row)
          end
        end
      }
    })
  self.register_converter(
    :table_iterator, :csv_file, lambda { |proc, options|
      CSV.open(options[:filename], 'wb', force_quotes: true) do |csv|
        proc.call do |row|
          csv << row
        end
      end
    })
end
