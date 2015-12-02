# require 'spreadsheet'
# require 'csv'

# record data have many representation formats:
#
# item_data: [{name: 'xx', value: 12}, ...]
# table_data: [['name', 'value'], ['xx', '12'], ..]
# item_iterator and table_iterator are iterators which yield each row
# csv_file and xls_file save the record data into files.
#
# this class is used for convert data between those types,
# so we can use it to easily export and import data.
# 
class DataListConverter
  TYPES = [:item_iterator, :table_iterator,
           :item_data, :table_data, :records,
           :csv_file, :xls_file,
          ]

  CONVERTS = [
    [:xls_file, :table_iterator],
    [:csv_file, :table_iterator],
    [:table_iterator, :item_iterator],
    [:item_data, :item_iterator],
    [:table_iterator, :table_data],
    [:records, :item_iterator],
  ]

  begin
    # Example:
    # convert(:item_iterator, :item_data, iter)
    # convert(:item_iterator, :csv_file, iter, csv_file: {filename: 'result.csv'})
    # convert(:item_iterator, :table_data, iter, table_iterator: {filter: :remove_debug})
    def convert(from_type, to_type, from_value, options={})
      route = find_route(from_type, to_type)

      filter_functions_for = lambda { |type|
        if filters = options[:filter] and filters = filters[type]
          [filters].flatten.map{|f| [type, "_", f].join}
        end
      }

      methods = (0..(route.length-2)).map do |i|
        from_type, to_type = route[i], route[i+1]
        [
          (filter_functions_for.call(from_type) if i == 0), # add first type filter
          "#{from_type}_to_#{to_type}",
          filter_functions_for.call(to_type),
        ].flatten.compact
      end.flatten
      chain_convert(methods, from_value, options)
    end

    def chain_convert(methods, from_value, options)
      methods.inject(from_value) do |v, method_name|
        self.method(method_name).call(v, options)
      end
    end

    # One type of data can be converted into any other types,
    # we have a list of convert methods: CONVERTS
    # If we want to convert between types, like: convert item_data into csv_file,
    # we need find all the intermidate data type, like: [:item_data, :item_iterator, :table_iterator, :csv_file]
    def find_route(from_type, to_type)
      raise Exception, "from_type should not equal to to_type: #{from_type}" if from_type == to_type
      out = find_next_node([], [from_type], route_map, to_type)
      raise Exception, "Route not found: #{from_type} -> #{to_type}" unless out
      out
    end

    # iterate through the type convert graph, and find the route
    def find_next_node (out, nodes, map, end_node)
      nodes.each do |node|
        return out + [node] if node == end_node
        next unless next_nodes = map[node]

        new_map = map.dup
        new_map.delete(node)
        result = find_next_node(out + [node], next_nodes, new_map, end_node)
        return result if result
      end
      return nil
    end
    private :find_next_node

    # convert adjacency list into quick lookup hash
    def route_map
      @route_map ||= \
      begin
        routes = CONVERTS.dup
        routes += routes.map(&:reverse)
        map = {}
        routes.each do |item|
          map[item.first] ||= []
          map[item.first] += [item[1]]
        end
        map
      end
    end

  end

  begin # convert functions

    def records_to_item_iterator(records, options)
      columns = options[:columns]
      lambda { |&block|
        records.find_each do |record|
          item = columns.map do |column|
            [column.first.to_sym, record.send(column[1])]
          end.to_h
          block.call(item)
        end
      }
    end

    def item_iterator_to_table_iterator(proc, options={})
      lambda { |&block|
        columns = nil
        proc.call do |item|
          unless columns
            columns = item.keys.map(&:to_sym)
            block.call(columns.map(&:to_s))
          end
          # item_iterator key can be symbol or string
          block.call(columns.map{ |c| item[c] || item[c.to_s] })
        end
      }
    end

    def table_iterator_to_item_iterator(proc, options={})
      lambda {|&block|
        columns = nil
        proc.call do |row|
          unless columns
            columns = row.map(&:to_sym)
          else
            block.call(columns.zip(row).to_h)
          end
        end
      }
    end

    def iterator_to_data(proc, options={})
      out = []
      proc.call { |d| out << d }
      out
    end
    alias_method :item_iterator_to_item_data, :iterator_to_data
    alias_method :table_iterator_to_table_data, :iterator_to_data

    def data_to_iterator(data, options={})
      lambda { |&block|
        data.each do |d|
          block.call(d)
        end
      }
    end
    alias_method :item_data_to_item_iterator, :data_to_iterator
    alias_method :table_data_to_table_iterator, :data_to_iterator

    def xls_file_to_table_iterator(proc, options)
      lambda { |&block|
        book = Spreadsheet.open(options[:filename])
        sheet = book.worksheet 0
        sheet.each do |row|
          block.call(row.to_a)
        end
      }
    end

    def table_iterator_to_xls_file(proc, options)
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet(name: (options[:sheet] || "Sheet1"))

      i = 0
      proc.call do |row|
        sheet.row(i).push *row
        i += 1
      end
      book.write(options[:filename])
    end

    def csv_file_to_table_iterator(proc, options)
      lambda { |&block|
        CSV.open(options[:filename]) do |csv|
          csv.each do |row|
            block.call(row)
          end
        end
      }
    end

    def table_iterator_to_csv_file(proc, options)
      CSV.open(options[:filename], 'wb', force_quotes: true) do |csv|
        proc.call do |row|
          csv << row
        end
      end
    end

  end

  begin # filters

    def table_iterator_remove_debug(proc, options)
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
    end

    def item_iterator_limit_size(proc, opt={})
      limit_size = opt[:limit] || 10
      lambda { |&block|
        limit = 0
        proc.call do |item|
          block.call(item)
          limit += 1
          break if limit >= limit_size
        end
      }
    end

  end    

  begin # helper functions

    def data_to_sheets_xls(data, filename)
      book = Spreadsheet::Workbook.new
      data.each do |k, v|
        sheet = book.create_worksheet name: k
        v.each_with_index do |d, i|
          sheet.row(i).concat d
        end
      end
      book.write(filename)
      filename
    end

    def sheets_xls_to_data(filename)
      book = Spreadsheet.open(filename)
      book.worksheets.map do |sheet|
        [sheet.name, sheet.map{|row| row.to_a}]
      end.to_h
    end

  end
end

