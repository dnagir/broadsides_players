require 'test/dn_strategic/test_helper'
require 'lib/dn_strategic/ship_discovery'

class ShipStepDiscoveryTest < Test::Unit::TestCase
  
  def test_falls_back_to_random_after_100_shots
    d = StepDiscovery.new
    100.times { d.next }    
    d.expects(:generate_default_next).returns('xxxx')
    assert_equal 'xxxx', d.next
  end
  
end
