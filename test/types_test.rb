require 'data_list_converter/types/csv_file'
require 'data_list_converter/types/xls_file'
require 'data_list_converter/types/xlsx_file'
require 'data_list_converter/types/marshal'

describe DataListConverter do
  before :all do
    @c = DataListConverter
  end

  describe :multi_sheet do
    specify do
      @c.convert(:multi_sheet_item_data, :multi_sheet_table_data, MULTI_SHEET_ITEM_DATA).must_equal(MULTI_SHEET_TABLE_DATA)
      @c.convert(:multi_sheet_table_data, :multi_sheet_item_data, MULTI_SHEET_TABLE_DATA).must_equal(MULTI_SHEET_ITEM_DATA)
    end
  end

  describe :csv_file do
    specify do
      begin
        @c.convert(:item_data, :csv_file, ITEM_DATA, csv_file: {filename: "test.csv"})
        @c.convert(:csv_file, :item_data, {filename: "test.csv"}).must_equal ITEM_DATA
        @c.convert(:item_data, :csv_raw, ITEM_DATA).must_equal CSV_DATA
        @c.convert(:csv_raw, :item_data, CSV_DATA).must_equal ITEM_DATA
      ensure
        FileUtils.rm_f("test.csv")
      end
    end
  end

  describe :xls_file do
    specify do
      begin
        @c.convert(:item_data, :xls_file, ITEM_DATA, xls_file: {filename: "test.xls"})
        @c.convert(:xls_file, :item_data, {filename: "test.xls"}).must_equal ITEM_DATA

        @c.convert(:multi_sheet_table_data, :xls_file, MULTI_SHEET_TABLE_DATA,
                   xls_file: {filename: 'test.xls'})
        @c.convert(:xls_file, :multi_sheet_table_data,
                   {filename: 'test.xls'},
                  ).must_equal(MULTI_SHEET_TABLE_DATA)
      ensure
        FileUtils.rm_f("test.xls")
      end
    end

  end

  describe :xlsx_file do
    specify do
      filename = 'test.xlsx'
      begin
        @c.convert(:item_data, :xlsx_file, ITEM_DATA, xlsx_file: {filename: filename})
        @c.convert(:xlsx_file, :item_data, {filename: filename}).must_equal ITEM_DATA

        @c.convert(:multi_sheet_table_data, :xlsx_file, MULTI_SHEET_TABLE_DATA,
                   xlsx_file: {filename: filename})
        @c.convert(:xlsx_file, :multi_sheet_table_data,
                   {filename: filename},
                  ).must_equal(MULTI_SHEET_TABLE_DATA)
      ensure
        FileUtils.rm_f(filename)
      end
    end

    it 'custom cell format' do
      begin
        data = {
          a: [['name'],
              [{text: 'bbb', change_font_color: '008800', change_font_size: 20}],
              [{text: 'aaa', change_fill: '880000'}],
             ],
        }
        @c.convert(:multi_sheet_table_data, :xlsx_file, data,
                   xlsx_file: {filename: 'test.xlsx'})
      ensure
        FileUtils.rm_f("test.xlsx")
      end
    end
  end

  require 'data_list_converter/types/fast_xlsx_file'

  describe :xlsx_file do
    specify do
      filename = 'test.xlsx'
      begin
        @c.convert(:item_data, :xlsx_file, ITEM_DATA, xlsx_file: {filename: filename})
        @c.convert(:xlsx_file, :item_data, {filename: filename}).must_equal ITEM_DATA

        @c.convert(:multi_sheet_table_data, :xlsx_file, MULTI_SHEET_TABLE_DATA,
                   xlsx_file: {filename: filename})
        @c.convert(:xlsx_file, :multi_sheet_table_data,
                   {filename: filename},
                  ).must_equal(MULTI_SHEET_TABLE_DATA)
      ensure
        FileUtils.rm_f(filename)
      end
    end

  end

  describe :marshal do
    specify do
      filename = 'test.marshal'
      begin
        @c.convert(:item_data, :marshal_file, ITEM_DATA, marshal_file: {filename: filename})
        @c.convert(:marshal_file, :item_data, {filename: filename}).must_equal ITEM_DATA
        @c.convert(:multi_sheet_table_data, :marshal_file, MULTI_SHEET_TABLE_DATA,
                   marshal_file: {filename: filename})
        @c.convert(:marshal_file, :multi_sheet_table_data,
                   {filename: filename},
                  ).must_equal(MULTI_SHEET_TABLE_DATA)

        data = {a: 12, b: 13}
        @c.convert(:raw, :marshal_file, data, marshal_file: {filename: filename})
        @c.convert(:marshal_file, :raw, {filename: filename}).must_equal(data)
      ensure
        FileUtils.rm_f(filename)
      end
    end
  end

  describe :records do
    specify do
      require 'sqlite3'
      require 'active_record'

      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: ':memory:'
      )

      ActiveRecord::Schema.define do
        create_table :users, force: true do |t|
          t.string :name
          t.integer :age
        end
      end

      class User < ActiveRecord::Base; end
      (1..10).each{ |i| User.create(name: "user-#{i}", age: i+20) }

      query = User.where("age > 25 and age < 27")
      columns = [:name, :age]
      @c.convert(:records, :item_data, query: query, columns: columns).
        must_equal([{name: "user-6", age: 26}])

      display = [:n, :a]
      @c.convert(:records, :item_data, query: query, columns: columns, display: display).
        must_equal([{n: "user-6", a: 26}])
    end
  end
  
end
