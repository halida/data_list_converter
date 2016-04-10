class DataListConverter
  def self.save_to_file(filename, data, data_format=:item_data)
    file_format = self.get_file_format(filename)
    DataListConverter.convert(data_format, file_format, data,
                              file_format => {filename: filename})
  end

  def self.load_from_file(filename, data_format=:item_data)
    file_format = self.get_file_format(filename)
    DataListConverter.convert(file_format, data_format,
                              {filename: filename})
  end

  def self.get_file_format(filename)
    file_type = (File.extname(filename)[1..-1] + "_file").to_sym
    unless DataListConverter.file_types.include?(file_type)
      raise "unknown file format: #{file_type}"
    end
    file_type
  end

  def self.types
    CONVERTERS.keys.flatten.uniq.sort
  end

  def self.file_types
    matcher = /(.*)_file$/
    DataListConverter.types.select do |type|
      matcher.match(type)
    end
  end
end
