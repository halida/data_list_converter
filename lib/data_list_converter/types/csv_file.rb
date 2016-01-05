require 'csv'

class DataListConverter
  self.register_converter(:csv_file, :table_iterator) do |input, options|
    lambda { |&block|
      CSV.open(input[:filename]) do |csv|
        csv.each do |row|
          block.call(row)
        end
      end
    }
  end

  self.register_converter(:table_iterator, :csv_file) do |proc, options|
    CSV.open(options[:filename], 'wb', force_quotes: true) do |csv|
      proc.call do |row|
        csv << row
      end
    end
    options[:filename]
  end
end
