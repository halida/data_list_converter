# xls_file only works when installed spreadsheet gem
# multi_sheet_data = {
#   'sheet1' => [columns, row, row, ...],
#   'sheet2' => [columns, row, row, ...],
# }
require 'spreadsheet'

class DataListConverter
  self.register_converter(
    :xls_file, :table_iterator, lambda { |input, options|
      lambda { |&block|
        book = Spreadsheet.open(input[:filename])
        sheet = book.worksheet input[:sheet] || 0
        sheet.each do |row|
          block.call(row.to_a)
        end
      }
    })
  self.register_converter(
    :table_iterator, :xls_file, lambda { |proc, options|
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet(name: (options[:sheet] || "Sheet1"))
      i = 0
      proc.call do |row|
        sheet.row(i).push *row
        i += 1
      end
      book.write(options[:filename])
      options[:filename]
    })

  self.register_converter(
    :multi_sheet_iterator, :xls_file, lambda { |data, options|
      book = Spreadsheet::Workbook.new
      data.each do |name, table_iterator|
        sheet = book.create_worksheet(name: name)
        i = 0
        table_iterator.call do |row|
          sheet.row(i).concat(row)
          i += 1
        end
      end
      filename = options[:filename]
      book.write(filename)
      filename
    })
  self.register_converter(
    :xls_file, :multi_sheet_iterator, lambda { |data, options|
      book = Spreadsheet.open(data[:filename])
      book.worksheets.map do |sheet|
        iterator = lambda { |&block|
          sheet.each do |row| 
            block.call(row.to_a)
          end
        }
        [sheet.name, iterator]
      end.to_h
    })
end
