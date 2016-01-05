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
                        msg: "%{percent}%"}}
      result = DataListConverter.convert(
        :item_iterator, :table_data, iter,
        item_iterator: {filter: filter})
      string.string.split("\n").must_equal ['total: 10000', '40.0%', '80.0%']
    end
  end
  
end
