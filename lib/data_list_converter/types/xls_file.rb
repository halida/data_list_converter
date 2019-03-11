# xls_file only works when installed spreadsheet gem
require 'spreadsheet'

class DataListConverter

  self.register_converter(:xls_file, :table_iterator) do |input, options|
    lambda { |&block|
      filename = self.parameter(input, :filename, :input)
      book = Spreadsheet.open(filename)
      sheet = book.worksheet input[:sheet] || 0
      sheet.each do |row|
        block.call(row.to_a)
      end
    }
  end

  self.register_converter(:table_iterator, :xls_file) do |proc, options|
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet(name: (options[:sheet] || "Sheet1"))
    i = 0
    proc.call do |row|
      row = row.map(&:to_s)
      sheet.row(i).push *row
      i += 1
    end
    filename = self.parameter(options, :filename, :xls_file)
    book.write(filename)
    filename
  end

  self.register_converter(:multi_sheet_table_iterator, :xls_file) do |data, options|
    book = Spreadsheet::Workbook.new
    data.each do |name, table_iterator|
      sheet = book.create_worksheet(name: name.to_s)
      i = 0
      table_iterator.call do |row|
        row = row.map(&:to_s)
        sheet.row(i).concat(row)
        i += 1
      end
    end
    filename = self.parameter(options, :filename, :xls_file)
    book.write(filename)
    filename
  end

  self.register_converter(:xls_file, :multi_sheet_table_iterator) do |input, options|
    filename = self.parameter(input, :filename, :input)
    book = Spreadsheet.open(filename)
    book.worksheets.map do |sheet|
      iterator = lambda { |&block|
        sheet.each do |row| 
          block.call(row.to_a)
        end
      }
      [sheet.name.to_sym, iterator]
    end.to_h
  end
end
