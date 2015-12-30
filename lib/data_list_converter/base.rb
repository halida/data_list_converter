# this class is used for convert data between types,
# so we can use it to easily export and import data.
# 
class DataListConverter
  CONVERTERS = {}
  FILTERS = {}

  class << self

    attr_accessor :debug

    def on_debug
      self.debug = true
      yield
    ensure
      self.debug = false
    end

    def log(msg)
      return unless debug
      puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\t#{msg}"
    end

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

      self.log("route: #{route}")
      (0..(route.length-2)).map do |i|
        from_type, to_type = route[i], route[i+1]
        method = CONVERTERS[[from_type, to_type]]
        raise "cannot find converter #{from_type} -> #{to_type}" unless method
        methods.push([method, options[to_type] || {}])
        add_filter.call(to_type)
      end

      self.log("methods: #{methods}")
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
      # map wide search
      checked = Set.new
      checking = Set.new([from_type])
      directions = {}

      while not checking.empty?
        current_node = checking.first

        next_nodes = route_map[current_node]
        # mark direction from from_type
        next_nodes.each do |node|
          # first marked is the shortest
          directions[node] ||= current_node
        end

        if next_nodes.include?(to_type)
          # get route
          start = to_type
          route = [start]
          while start != from_type
            previous = directions[start]
            raise "cannot find previous for #{start} in #{directions}" if not previous
            route.push(previous)
            start = previous
          end
          return route.reverse
        else
          checking.delete(current_node)
          checked.add(current_node)
          checking += Set.new(next_nodes) - checked
        end
      end
      raise Exception, "Route not found: #{from_type} -> #{to_type}"
    end

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
