class DataListConverter
  def self.save_to_file(filename, data, data_format=:item_data, options={})
    file_format = self.get_file_format(filename)
    options[file_format] = {filename: filename}
    DataListConverter.convert(data_format, file_format, data, options)
  end

  def self.load_from_file(filename, data_format=:item_data, options={})
    file_format = self.get_file_format(filename)
    options[:filename] = filename
    DataListConverter.convert(file_format, data_format, options)
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

  def self.routes
    CONVERTERS.keys
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
  def self.flatten(data, sep=':', max_level=nil)
    out = {}
    recursive_flatten(out, data, nil, sep, 1, max_level)
    out
  end

  def self.recursive_flatten(out, data, header, sep, level, max_level)
    data.each do |k, v|
      k = header ? :"#{header}#{sep}#{k}" : k
      if v.kind_of?(Hash) and (!max_level or level <= max_level)
        recursive_flatten(out, v, k, sep, level+1, max_level)
      else
        out[k] = v
      end
    end
  end

  def self.parameter(data, key, type)
    raise Exception, "`#{type}` should be hash, not `#{data.class}`: #{data}" unless data.kind_of?(Hash)
    raise Exception, "Need `#{key}` for `#{type}`, current: #{data}" if not data.has_key?(key)
    data.fetch(key)
  end

end
