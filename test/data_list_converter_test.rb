require 'minitest/pride'
require 'minitest/autorun'

require 'data_list_converter'

ITEM_DATA = [
  {name: "James", score: '12'},
  {name: "Bob", score: '33'},
]

TABLE_DATA = [
  ['name', 'score'],
  ['James', '12'],
  ['Bob', '33']
]

describe DataListConverter do
  describe :convert do
    before :all do
      @c = DataListConverter.new
    end
    
    it 'works' do
      @c.convert(:item_data, :table_data, ITEM_DATA).must_equal TABLE_DATA
    end
  end
end
