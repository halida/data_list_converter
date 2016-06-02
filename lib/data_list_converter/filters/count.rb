class DataListConverter
  self.register_filter(:item_iterator, :count) do |proc, options|
    count = 0
    size = options[:size] || 100
    msg_format = options[:msg] || "on %{count}"
    total_format = options[:total] || "total: %{total}"
    out = options[:out] || STDOUT

    total = 1
    lambda { |&block|
      proc.call do |item|
        if item.keys == [:total]
          total = item[:total]
          out.write(total_format % {total: total})
          out.write("\n")
        else
          block.call(item)
          count += 1
          msg = msg_format % {count: count, percent: (count / total.to_f * 100).round(2)}
          out.write(msg + "\n") if count % size == 0
        end
      end
    }
  end
end


