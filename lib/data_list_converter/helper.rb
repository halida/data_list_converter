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

  # sometimes item data keys don't exactly same, like:
  #   [{a: 12}, {b: 11}]
  # should update to:
  #   [{a: 12, b: nil}, {a: nil, b: 11}]
  # so it can be convent to table data
  def self.unify_item_data_keys(list)
    keys = Set.new
    list.each do |item|
      keys += item.keys
    end
    list.each do |item|
      keys.each do |key|
        item[key] ||= nil
      end
    end
  end

  # flatten multi level item data into one level, example:
  #   {a: {b: 12}, c: {d: {e: 11}}}
  #   =>
  #   {:"a:b"=>12, :"c:d:e"=>11}
  def self.flatten(data, sep=':')
    out = {}
    recursive_flatten(out, data, nil, sep)
    out
  end

  def self.recursive_flatten(out, data, header, sep)
    data.each do |k, v|
      k = header ? :"#{header}#{sep}#{k}" : k
      case v
      when Hash
        recursive_flatten(out, v, k, sep)
      else
        out[k] = v
      end
    end
  end

end
