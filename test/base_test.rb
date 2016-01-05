describe DataListConverter do
  before :all do
    @c = DataListConverter
  end

  describe :convert do
    specify do
      @c.convert(:item_data, :table_data, ITEM_DATA).must_equal TABLE_DATA
    end

    it 'has parameters' do
      begin
        @c.convert(:item_data, :csv_file, ITEM_DATA, csv_file: {filename: "test.csv"})
        File.read("test.csv").strip.must_equal CSV_DATA
        @c.convert(:csv_file, :item_data, {filename: "test.csv"}).must_equal(ITEM_DATA)
      ensure
        FileUtils.rm_f("test.csv")
      end
    end

    it 'has filters' do
      filter = :limit
      item_data = [{name: "james"}] * 20
      result = @c.convert(:item_data, :table_data, item_data,
                          item_iterator: {filter: filter})
      result.must_equal([["name"]] + [["james"]]*10)
      
      filter = {limit: {size: 2}}
      item_data = [{name: "james"}] * 10
      result = @c.convert(:item_data, :table_data, item_data,
                          item_iterator: {filter: filter})
      result.must_equal [["name"], ["james"], ["james"]]

      string = StringIO.new
      filter = [{limit: {size: 12}}, {count: {size: 4, out: string, msg: ".%{count}"}}]
      item_data = [{name: "james"}] * 20
      result = @c.convert(:item_data, :table_data, item_data,
                          item_iterator: {filter: filter})
      result.must_equal([["name"]] + [["james"]]*12)
      string.string.must_equal ".4\n.8\n.12\n"
    end

  end

end
