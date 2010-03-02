require 'test/dn_strategic/test_helper'

class StringExtensionsTest < Test::Unit::TestCase

  def test_x_coords
    { 'A5' => 0, 'B6' => 1, 'J10' => 9 }.each_pair do |pos, expecting|
      assert_equal expecting, pos.x
    end
  end
  
  def test_y_coords
    { 'A5' => 4, 'B6' => 5, 'J10' => 9 }.each_pair do |pos, expecting|
      assert_equal expecting, pos.y
    end
  end

  def test_move_to_left
    {'A1' => nil, 'C1' => 'B1', 'B5' => 'A5', 'J10' => 'I10', nil => nil}.each_pair do |from, to|
        assert_equal to, from.to_left
      end
  end
  
  def test_move_to_right
    {'A1' => 'B1', 'B1' => 'C1', 'A5' => 'B5', 'J10' => nil, nil => nil}.each_pair do |from, to|
        assert_equal to, from.to_right
      end
  end
  
  def test_move_to_up
    {'A1' => nil, 'B2' => 'B1', 'D5' => 'D4', 'A10' => 'A9', nil => nil}.each_pair do |from, to|
        assert_equal to, from.to_up
      end
  end
  
  def test_move_to_dn
    {'A1' => 'A2', 'B2' => 'B3', 'D5' => 'D6', 'J10' => nil, nil => nil}.each_pair do |from, to|
        assert_equal to, from.to_dn
      end
  end

end
