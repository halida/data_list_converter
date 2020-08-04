# multi_sheet_table_data = {
#   'sheet1' => [columns, row, row, ...],
#   'sheet2' => [columns, row, row, ...],
# }
# also:
# multi_sheet_item_data
# multi_sheet_table_iterator
# multi_sheet_item_iterator

class DataListConverter

  MULT_SHEET_CONVERTS = [[:table_data, :table_iterator],
                         [:item_data, :item_iterator],
                         [:table_iterator, :item_iterator],
                        ]
  (MULT_SHEET_CONVERTS + MULT_SHEET_CONVERTS.map(&:reverse)).each do |i|
    from_type, to_type = i
    self.register_converter(
      :"multi_sheet_#{from_type}",
      :"multi_sheet_#{to_type}",
    ) do |data, options|
      self.log("multi_sheet #{from_type} -> #{to_type} with options: #{options}")
      data.map do |sheet, from_data|
        to_data = self.convert(from_type, to_type, from_data, options)
        [sheet, to_data]
      end.to_h
    end
  end

end
