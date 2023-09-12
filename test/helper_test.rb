require 'data_list_converter/types/csv_file'
require 'data_list_converter/types/xls_file'
require 'data_list_converter/types/xlsx_file'
require 'data_list_converter/types/fast_xlsx_file'
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
         :csv_file, :csv_raw, :fast_xlsx_file, :xls_file, :xlsx_file,
         :records, :raw,
        ].sort
      )
    end
  end

  describe :file_types do
    specify do
      @c.file_types.must_equal(
        [
          :csv_file, :fast_xlsx_file, :xlsx_file, :xls_file, :marshal_file
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
      data = [{a: '12', b: '3'}, {a: '1', b: '4'}]
      table_data = [['a', 'b'], ['a1', 'b1']]

      begin
        @c.save_to_file(filename, data)
        @c.load_from_file(filename).must_equal(data)

        @c.save_to_file(filename, table_data, :table_data)
        @c.load_from_file(filename, :table_data).must_equal(table_data)
      ensure
        FileUtils.rm_rf(filename)
      end

      filename = "result.xlsx"
      begin
        @c.save_to_file(filename, data, :item_data, file_format: :fast_xlsx_file)
        @c.load_from_file(filename, :item_data, file_format: :fast_xlsx_file).must_equal(data)

        @c.save_to_file(filename, table_data, :table_data, file_format: :fast_xlsx_file)
        @c.load_from_file(filename, :table_data, file_format: :fast_xlsx_file).must_equal(table_data)
      ensure
        FileUtils.rm_rf(filename)
      end
    end
  end

  describe :unify_item_data_keys do
    specify do
      list = [{a: 12}, {b: 11}]
      @c.unify_item_data_keys(list)
      list.must_equal([{a: 12, b: nil}, {a: nil, b: 11}])
    end
  end


  describe :flatten do
    specify do
      data = {a: {b: 12}, c: {d: {e: 11}}}
      @c.flatten(data).must_equal({:"a:b"=>12, :"c:d:e"=>11})

      # change sep
      data = {a: {b: 12}, c: {d: {e: 11}}}
      @c.flatten(data, '_').must_equal({:"a_b"=>12, :"c_d_e"=>11})

      # set max level
      data = {a: {b: 12}, c: {d: {e: {f: 11}}}}
      @c.flatten(data, ':', 1).must_equal({:"a:b"=>12, :"c:d"=>{e: {f: 11}}})
      data = {a: {b: 12}, c: {d: {e: {f: 11}}}}
      @c.flatten(data, ':', 2).must_equal({:"a:b"=>12, :"c:d:e"=>{f: 11}})
    end
  end
end
