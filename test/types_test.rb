describe DataListConverter do
  before :all do
    @c = DataListConverter
  end

  describe :type do
    specify do
      DataListConverter.types.must_equal(
        [:item_data, :item_iterator,
         :table_data, :table_iterator,
         :multi_sheet_item_data,
         :multi_sheet_table_data,
         :multi_sheet_item_iterator,
         :multi_sheet_table_iterator,
         :csv_file, :xls_file, :xlsx_file,
         :records,
        ].sort
      )
    end
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
      begin
        @c.convert(:item_data, :xlsx_file, ITEM_DATA, xlsx_file: {filename: "test.xlsx"})
        @c.convert(:xlsx_file, :item_data, {filename: "test.xlsx"}).must_equal ITEM_DATA

        @c.convert(:multi_sheet_table_data, :xlsx_file, MULTI_SHEET_TABLE_DATA,
                   xlsx_file: {filename: 'test.xlsx'})
        @c.convert(:xlsx_file, :multi_sheet_table_data,
                   {filename: 'test.xlsx'},
                  ).must_equal(MULTI_SHEET_TABLE_DATA)
      ensure
        FileUtils.rm_f("test.xlsx")
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
end
