class DataListConverter
  def self.iterator_limit(proc, options)
    limit_size = options[:size] || 10
    lambda { |&block|
      limit = 0
      proc.call do |item|
        block.call(item)
        limit += 1
        break if limit >= limit_size
      end
    }
  end
  self.register_filter(
    :item_iterator, :limit, self.method(:iterator_limit))
  self.register_filter(
    :table_iterator, :limit, self.method(:iterator_limit))
end
