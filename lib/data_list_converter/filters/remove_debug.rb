class DataListConverter
  self.register_filter(
    :table_iterator, :remove_debug, lambda{ |proc, options|
      lambda { |&block|
        columns = nil
        debug_index = nil
        proc.call do |row|
          unless columns
            columns = row
            debug_index = columns.index('debug')
          end
          block.call(row[0..(debug_index-1)])
        end
      }
    })
end
