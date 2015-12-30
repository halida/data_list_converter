# xlsx_file only works when installed rubyXL gem
# multi_sheet_data = {
#   'sheet1' => [columns, row, row, ...],
#   'sheet2' => [columns, row, row, ...],
# }
require 'rubyXL'

class DataListConverter
  self.register_converter(
    :xlsx_file, :table_iterator, lambda { |input, options|
      lambda { |&block|
        book = RubyXL::Parser.parse(input[:filename])
        sheet = book.worksheets[input[:sheet] || 0]
        sheet.each do |row|
          block.call(row.cells.map(&:value))
        end
      }
    })
  self.register_converter(
    :table_iterator, :xlsx_file, lambda { |proc, options|
      book = RubyXL::Workbook.new
      sheet = book.worksheets[0]
      sheet.sheet_name = options[:sheet] if options[:sheet]
      i = 0
      proc.call do |row|
        row.each_with_index do |v, j|
          sheet.add_cell(i, j, v)
        end
        i += 1
      end
      filename = options[:filename]
      book.write(filename)
      filename
    })

  self.register_converter(
    :multi_sheet_iterator, :xlsx_file, lambda { |data, options|
      book = RubyXL::Workbook.new
      book.worksheets.pop
      data.each do |name, table_iterator|
        sheet = book.add_worksheet(name)
        i = 0
        table_iterator.call do |row|
          row.each_with_index do |v, j|
            sheet.add_cell(i, j, v)
          end
          i += 1
        end
      end
      filename = options[:filename]
      book.write(filename)
      filename
    })
  self.register_converter(
    :xlsx_file, :multi_sheet_iterator, lambda { |data, options|
      book = RubyXL::Parser.parse(data[:filename])
      book.worksheets.map do |sheet|
        iterator = lambda { |&block|
          sheet.each do |row|
            block.call(row.cells.map(&:value))
          end
        }
        [sheet.sheet_name, iterator]
      end.to_h
    })
end
