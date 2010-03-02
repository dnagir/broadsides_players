# The player itslef
class Player
  attr_accessor :field
  
  def initialize
    @discovery = StepDiscovery.new(:transform)
    @field = {}
    @shot_queue = []
  end
  
  
  # Returns the player name as used on the server
  def name
    File.basename(__FILE__, '.rb')
  end
      
  def shootable?(here)
    return false unless here
    # there are MISSes all around - cannot be the target
    # Do not take into account out-of-bounds
    around = [here.to_left, here.to_right, here.to_up, here.to_dn].reject { |l| l.nil? }
    around = around.map { |l| field[l] } # from locations to the values
    return false if !around.empty? && around.all? { |l| l == :miss }
    field[here].nil?
  end
  
  # Returns next position from the sequence to shot at. Examples: A1, B10, J9
  def next_target
    # First shot at the priority positions
    begin
      here = @shot_queue.shift
    end while !shootable?(here) && !@shot_queue.empty?
    
    while !shootable?(here) do    
      here = @discovery.next
    end    
    field[here] = :shot if here
    here
  end
  
  # Returns ships' positions as per server. Includes only the actual positions with no message.
  def allocate_ships
    options =[
     "5:A1:V 4:J5:V 3:A8:H 3:I1:V 2:D1:H",
     "5:I1:V 4:H6:V 3:E10:H 3:D7:V 2:B3:V"
    ]
    options.last#[rand options.length]
  end
  
  # Receives count
  # Returns space delimited positions. Such as "A1 J10"
  def shot(count)
    shots = (1..count).map do
      next_target
    end * ' '
    shots
  end
  
  # Expecting string: "A1:hit B10:miss"
  # Processes the result, marks the field appropriately, changes the sequence of shots accordingly.
  def process_shot_result(shot_result)
    # split
    shot_result.split(/:|\s/).each_slice(2) do |location, result|
      field[location] = result.to_sym      
      self.send("has_#{result}", location)
    end
  end
  
  # Callback for an on-target shot
  def has_hit(hit)
    # Force shooting around
    [ hit.to_left, 
      hit.to_right, 
      hit.to_up, 
      hit.to_dn
    ].reject { |l| l.nil? } .each { |l| @shot_queue.push l }    
  end
  
  # Callback for a missed shot
  def has_miss(location)
  end
end

