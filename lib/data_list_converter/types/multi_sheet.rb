# multi_sheet_data = {
#   'sheet1' => [columns, row, row, ...],
#   'sheet2' => [columns, row, row, ...],
# }
class DataListConverter

  self.register_converter(:multi_sheet_iterator, :multi_sheet_data) do |data, options|
    options[:type] ||= :item_data
    data.map do |k, iter|
      data = self.convert(:table_iterator, options[:type], iter)
      [k, data]
    end.to_h
  end

  self.register_converter(:multi_sheet_data, :multi_sheet_iterator) do |data, options|
    options[:type] ||= :table_data
    data.map do |k, v|
      iter = self.convert(options[:type], :table_iterator, v)
      [k, iter]
    end.to_h
  end

end
