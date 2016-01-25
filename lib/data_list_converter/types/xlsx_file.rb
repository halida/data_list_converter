# xlsx_file only works when installed rubyXL gem
require 'rubyXL'

class DataListConverter

  self.register_converter(:xlsx_file, :table_iterator) do |input, options|
    lambda { |&block|
      book = RubyXL::Parser.parse(input[:filename])
      sheet = book.worksheets[input[:sheet] || 0]
      sheet.each do |row|
        block.call(row.cells.map(&:value))
      end
    }
  end

  self.register_converter(:table_iterator, :xlsx_file) do |proc, options|
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
  end

  self.register_converter(:multi_sheet_table_iterator, :xlsx_file) do |data, options|
    book = RubyXL::Workbook.new
    book.worksheets.pop
    data.each do |name, table_iterator|
      sheet = book.add_worksheet(name.to_s)
      i = 0
      table_iterator.call do |row|
        row.each_with_index do |v, j|
          if v.kind_of?(Hash)
            # custom cell format
            cell = sheet.add_cell(i, j, v[:text])
            v.each do |k, v|
              next if k == :text
              cell.send(k, v)
            end
            cell.change_fill(v[:fill_color]) if v[:fill_color]
          else
            cell = sheet.add_cell(i, j, v)
          end

        end
        i += 1
      end
    end
    filename = options[:filename]
    book.write(filename)
    filename
  end

  self.register_converter(:xlsx_file, :multi_sheet_table_iterator) do |data, options|
    book = RubyXL::Parser.parse(data[:filename])
    book.worksheets.map do |sheet|
      iterator = lambda { |&block|
        sheet.each do |row|
          next unless row
          block.call(row.cells.map(&:value))
        end
      }
      [sheet.sheet_name.to_sym, iterator]
    end.to_h
  end
end
