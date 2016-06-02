class DataListConverter

  def self.marshal_file_to_data(input, options=nil)
    filename = self.parameter(input, :filename, :input)
    File.open(filename) do |f|
      Marshal.load(f)
    end
  end

  def self.marshal_data_to_file(data, options)
    filename = self.parameter(options, :filename, :marshal)
    File.open(filename, 'w+') do |f|
      Marshal.dump(data, f)
    end
    options[:filename]
  end

  [:raw, :table_data, :multi_sheet_table_data].each do |type|
    self.register_converter(:marshal_file, type) do |input, options|
      self.marshal_file_to_data(input, options)
    end
    self.register_converter(type, :marshal_file) do |data, options|
      self.marshal_data_to_file(data, options)
    end
  end

end
