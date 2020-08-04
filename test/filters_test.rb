describe DataListConverter do
  before :all do
    @c = DataListConverter
  end

  describe :limit do
    specify do
      filter = {limit: {size: 2}}
      item_data = [{name: "james"}] * 10
      result = DataListConverter.convert(
        :item_data, :table_data, item_data,
        item_iterator: {filter: filter})
      result.must_equal [["name"], ["james"], ["james"]]
    end
  end

  describe :count do
    specify do
      iter = lambda { |&block|
        total = 10000
        block.call(total: total)
        (1..total-1).each do |i|
          block.call(id: i, value: i*i)
        end
      }
      string = StringIO.new
      filter = {count: {size: 4000,
                        out: string,
                        msg: "%{percent}%%"}}
      result = DataListConverter.convert(
        :item_iterator, :table_data, iter,
        item_iterator: {filter: filter})
      string.string.split("\n").must_equal ['total: 10000', '40.0%', '80.0%']
    end
  end

  describe :remove_debug do
    specify do
      filter = {remove_debug: true}
      item_data = [{name: "james", debug: "", a: 12}] * 2
      result = DataListConverter.convert(
        :item_data, :table_data, item_data,
        table_iterator: {filter: filter})
      result.must_equal [["name"], ["james"], ["james"]]

      # check on multi_sheet
      item_data = {a: [{name: "james", debug: "", a: 12}] * 2, b: [{name: 'cc', debug: "", b: 3}]*3}
      result = DataListConverter.convert(
        :multi_sheet_item_data, :multi_sheet_table_data, item_data,
        multi_sheet_table_iterator: {table_iterator: {filter: {remove_debug: true}}})
      result.must_equal(a: [["name"], ["james"], ["james"]], b: [["name"], ["cc"], ["cc"], ["cc"]])
    end
  end
  
end
