class DataListConverter
  self.register_filter(:table_iterator, :remove_debug) do |proc, options|
    lambda { |&block|
      columns = nil
      debug_index = nil
      proc.call do |row|
        unless columns
          columns = row
          debug_index = columns.index('debug') || columns.index('Debug')
        end

        if debug_index != nil
          block.call(row[0..(debug_index-1)])
        else
          block.call(row)
        end
      end
    }
  end
end
