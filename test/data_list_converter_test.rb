require 'minitest/pride'
require 'minitest/autorun'

require 'data_list_converter'

load 'test/testdata.rb'

describe DataListConverter do
  describe :type do
    it 'works' do
      DataListConverter.types.must_equal(
        [:csv_file, :item_data, :item_iterator, :multi_sheet_data, :multi_sheet_iterator,
         :records, :table_data, :table_iterator, :xls_file, :xlsx_file])
    end
  end

  describe :convert do
    before :all do
      @c = DataListConverter
    end
    
    it 'works' do
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

    it 'has type xls_file' do
      begin
        @c.convert(:item_data, :xls_file, ITEM_DATA, xls_file: {filename: "test.xls"})
        @c.convert(:xls_file, :item_data, {filename: "test.xls"}).must_equal ITEM_DATA

        multi_sheet = {
          "sheet1" => [['name'], ['james'], ['bob']],
          "sheet2" => [['value'], ['21'], ['12']],
        }
        @c.convert(:multi_sheet_data, :xls_file, multi_sheet, xls_file: {filename: 'test.xls'})
        @c.convert(:xls_file, :multi_sheet_data,
                   {filename: 'test.xls'},
                   multi_sheet_data: {type: :table_data},
                  ).must_equal multi_sheet
      ensure
        FileUtils.rm_f("test.xls")
      end
    end

    it 'has type xlsx_file' do
      begin
        @c.convert(:item_data, :xlsx_file, ITEM_DATA, xlsx_file: {filename: "test.xlsx"})
        @c.convert(:xlsx_file, :item_data, {filename: "test.xlsx"}).must_equal ITEM_DATA

        multi_sheet = {
          "sheet1" => [['name'], ['james'], ['bob']],
          "sheet2" => [['value'], ['21'], ['12']],
        }
        @c.convert(:multi_sheet_data, :xlsx_file, multi_sheet, xlsx_file: {filename: 'test.xlsx'})
        @c.convert(:xlsx_file, :multi_sheet_data,
                   {filename: 'test.xlsx'},
                   multi_sheet_data: {type: :table_data},
                  ).must_equal multi_sheet
      ensure
        FileUtils.rm_f("test.xlsx")
      end
    end
  end

  describe :filters do
    it 'limit iterator' do
      filter = {limit: {size: 2}}
      item_data = [{name: "james"}] * 10
      result = DataListConverter.convert(
        :item_data, :table_data, item_data,
        item_iterator: {filter: filter})
      result.must_equal [["name"], ["james"], ["james"]]
    end

    it 'count item_iterator' do
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
