require 'data_list_converter/types/csv_file'
require 'data_list_converter/types/xls_file'
require 'data_list_converter/types/xlsx_file'
require 'data_list_converter/types/marshal'

describe DataListConverter do

  before :all do
    @c = DataListConverter
  end

  describe :types do
    specify do
      @c.types.must_equal(
        [:item_data, :item_iterator,
         :table_data, :table_iterator,
         :multi_sheet_item_data,
         :multi_sheet_table_data,
         :multi_sheet_item_iterator,
         :multi_sheet_table_iterator,
         :marshal_file,
         :csv_file, :csv_raw, :xls_file, :xlsx_file,
         :records, :raw,
        ].sort
      )
    end
  end

  describe :file_types do
    specify do
      @c.file_types.must_equal(
        [
          :csv_file, :xlsx_file, :xls_file, :marshal_file
        ].sort
      )
    end
  end

  describe :get_file_format do
    specify do
      @c.get_file_format('sss.xlsx').must_equal(:xlsx_file)
      @c.get_file_format('sss.csv').must_equal(:csv_file)
      @c.get_file_format('sss.marshal').must_equal(:marshal_file)
      -> { @c.get_file_format('sss.bak') }.must_raise RuntimeError
    end
  end

  describe :load_and_save_to_file do
    specify do
      filename = 'result.csv'
      begin
        data = [{a: '12', b: '3'}, {a: '1', b: '4'}]
        @c.save_to_file(filename, data)
        @c.load_from_file(filename).must_equal(data)

        table_data = [['a', 'b'], ['a1', 'b1']]
        @c.save_to_file(filename, table_data, :table_data)
        @c.load_from_file(filename, :table_data).must_equal(table_data)
      ensure
        FileUtils.rm_rf(filename)
      end
    end
  end

end
