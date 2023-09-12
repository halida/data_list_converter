require 'xlsxtream'
require 'creek'

# usage:
# require 'data_list_converter/types/fast_xlsx_file'
# d = [{a: 12.3, b: 'xx'}]
# DataListConverter.save_to_file("t.xls", d, :item_data, file_format: :fast_xlsx_file)

class DataListConverter

  self.register_converter(:fast_xlsx_file, :table_iterator) do |input, options|
    lambda { |&block|
      filename = self.parameter(input, :filename, :input)

      creek = Creek::Book.new filename
      sheet = creek.sheets[input[:sheet] || 0]
      sheet.rows.each do |row|
        block.call(row.values)
      end
    }
  end

  self.register_converter(:fast_xlsx_file, :multi_sheet_table_iterator) do |input, options|
    filename = self.parameter(input, :filename, :input)

    creek = Creek::Book.new filename
    creek.sheets.map do |sheet|
      iterator = lambda { |&block|
        sheet.rows.each do |row|
          block.call(row.values)
        end
      }
      [sheet.name.to_sym, iterator]
    end.to_h
  end

  self.register_converter(:table_iterator, :fast_xlsx_file) do |proc, options|
    filename = self.parameter(options, :filename, :fast_xlsx_file)
    Xlsxtream::Workbook.open(filename) do |xlsx|
      xlsx.write_worksheet (options[:sheet] || "Sheet1") do |sheet|
        proc.call do |row|
          sheet << row
        end
      end
    end
    filename
  end

  self.register_converter(:multi_sheet_table_iterator, :fast_xlsx_file) do |data, options|
    filename = self.parameter(options, :filename, :fast_xlsx_file)
    Xlsxtream::Workbook.open(filename) do |xlsx|
      data.each do |name, table_iterator|
        xlsx.write_worksheet(name.to_s) do |sheet|
          table_iterator.call do |row|
            sheet << row
          end
        end
      end
    end
    filename
  end

end
