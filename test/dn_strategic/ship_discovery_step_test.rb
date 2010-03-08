require 'test/dn_strategic/test_helper'
require 'lib/dn_strategic/ship_discovery'

class ShipStepDiscoveryTest < Test::Unit::TestCase
  
  def test_returns_nil_after_100_shots
    d = ShipDiscovery.new
    100.times { d.next }    
    assert_nil d.next
  end
  
end
