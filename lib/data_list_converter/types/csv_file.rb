require 'csv'

class DataListConverter
  self.register_converter(:csv_file, :table_iterator) do |input, options|
    lambda { |&block|
      filename = self.parameter(input, :filename, :input)
      CSV.open(filename) do |csv|
        csv.each do |row|
          block.call(row)
        end
      end
    }
  end

  self.register_converter(:table_iterator, :csv_file) do |proc, options|
    filename = self.parameter(options, :filename, :csv_file)
    CSV.open(filename, 'wb', force_quotes: true) do |csv|
      proc.call do |row|
        csv << row
      end
    end
    options[:filename]
  end

  self.register_converter(:table_iterator, :csv_raw) do |proc, options|
    CSV.generate(force_quotes: true) do |csv|
      proc.call do |row|
        csv << row
      end
    end
  end

  self.register_converter(:csv_raw, :table_iterator) do |input, options|
    lambda { |&block|
      CSV.parse(input).each do |row|
        block.call(row)
      end
    }
  end
end
