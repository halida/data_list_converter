# this class is used for convert data between types,
# so we can use it to easily export and import data.
# 
class DataListConverter
  CONVERTERS = {}
  FILTERS = {}

  class << self

    def types
      CONVERTERS.keys.flatten.uniq.sort
    end

    def register_converter(from_type, to_type, method)
      @route_map = nil # clear cache
      CONVERTERS[[from_type, to_type]] = method
    end

    def register_filter(type, name, method)
      FILTERS[type] ||= {}
      FILTERS[type][name] = method
    end

    # Example:
    # convert(:item_iterator, :item_data, iter)
    # convert(:item_iterator, :csv_file, iter, csv_file: {filename: 'result.csv'})
    # convert(:csv_file, :item_data, {filename: 'result.csv'})
    #
    # can add filter:
    # filter = :limit
    # filter = {limit: {size: 2}}
    # filter = [{limit: {size: 12}}, {count: {size: 4}}]
    # convert(:item_iterator, :table_data, iter, table_iterator: {filter: filter})
    def convert(from_type, to_type, from_value, options={})
      methods = []
      add_filter = lambda { |type|
        filters = (options[type] || {}).delete(:filter)
        return unless filters
        methods += normalize_filters(type, filters)
      }

      route = find_route(from_type, to_type)
      add_filter.call(route[0])

      (0..(route.length-2)).map do |i|
        from_type, to_type = route[i], route[i+1]
        method = CONVERTERS[[from_type, to_type]]
        raise "cannot find converter #{from_type} -> #{to_type}" unless method
        methods.push([method, options[to_type] || {}])
        add_filter.call(to_type)
      end

      methods.inject(from_value) do |v, method|
        method, args = method
        method.call(v, args)
      end
    end

    def normalize_filters(type, filters)
      # filter list as array
      filters = [filters] unless filters.kind_of?(Array)
      filters.map do |v|
        # fix filter arguments
        case v
        # {:limit, {count: 12}} => [:limit, {count: 12}]
        when Hash; v.first
        # :debug => [:debug, {}]
        when Symbol, String; [v, {}]
        else; v
        end
      end.map do |name, args|
        method = FILTERS[type][name] rescue raise("cannot find method for type #{type} filter #{name}")
        [method, args]
      end
    end

    # One type of data can be converted into any other types,
    # we have a list of convert methods: CONVERTERS
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
      nil
    end
    private :find_next_node

    # convert adjacency list into quick lookup hash
    def route_map
      @route_map ||= \
      begin
        CONVERTERS.keys.
          inject({}) do |map, item|
          map[item.first] ||= []
          map[item.first] += [item[1]]
          map
        end
      end
    end

  end
end
