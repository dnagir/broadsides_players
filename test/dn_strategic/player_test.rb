require 'test/dn_strategic/test_helper'
require 'lib/dn_strategic/ship_discovery'
require 'lib/dn_strategic/player'

class PlayerTest < Test::Unit::TestCase
  TEST_FIELD = {
    'A1' => :miss, 'B1' => :miss,                'D1' => :miss,
    'A2' => :hit,  'B2' => :miss, 'C2' => :miss,                'E2' => :miss,
    'A3' => :hit,                 'C3' => :miss, 'D3' => :miss, 'E3' => :miss,
    
    'A9' => :miss,                                                              'J9' => :miss,
                    'B10' => :miss
  }
  
  def test_shootable
    p = Player.new
    p.stubs(:field).returns(TEST_FIELD)
    
    ['A1', 'B1', 'C1', 'B2', 'D1', 'A2', 'D2', 'A10'].each do |pos|
      assert !p.shootable?(pos)
    end
    ['B3', 'J10'].each do |pos|
      assert p.shootable?(pos)
    end
    
  end
  
  def test_next_target
    p = Player.new
    assert_not_nil p.next_target
  end
  
end
