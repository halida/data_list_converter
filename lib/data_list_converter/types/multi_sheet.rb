class DataListConverter

  self.register_converter(
    :multi_sheet_iterator, :multi_sheet_data, lambda { |data, options|
      data.map do |k, iter|
        data = self.convert(:table_iterator, :table_data, iter)
        [k, data]
      end.to_h
    })

  self.register_converter(
    :multi_sheet_data, :multi_sheet_iterator, lambda { |data, options|
      data.map do |k, v|
        iter = self.convert(:table_data, :table_iterator, v)
        [k, iter]
      end.to_h
    })
  
end
