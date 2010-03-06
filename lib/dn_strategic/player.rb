# The player itslef
class Player
  attr_accessor :field
  
  def initialize
    @discovery = ShipDiscovery.new(:transform)
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
    # Then shot according to ship discovery
    while !shootable?(here) do
      here = @discovery.next
      break if here.nil?
    end    
    field[here] = :shot if here
    here
  end
  
  # Returns ships' positions as per server. Includes only the actual positions with no message.
  def allocate_ships
    options =[
     "5:A1:V 4:J5:V 3:A8:H 3:I1:V 2:!?:H".sub('!', ('C'..'G').sort_by { rand }.first).sub('?', (1..9).sort_by{ rand }.first.to_s),
     "5:I1:V 4:H6:V 3:E10:H 3:D7:V 2:!?:V".sub('!', ('A'..'G').sort_by { rand }.first).sub('?', (1..4).sort_by{ rand }.first.to_s),
     "5:E3:V 4:A2:V 3:A7:V 3:J5:V 2:!?:V".sub('!', ('G'..'I').sort_by { rand }.first).sub('?', (1..9).sort_by{ rand }.first.to_s),
     "5:F10:H 4:A10:H 3:A2:V 3:H1:H 2:!?:H".sub('!', ('C'..'I').sort_by { rand }.first).sub('?', (3..8).sort_by{ rand }.first.to_s),
     "5:B1:H 4:J2:V 3:J7:V 3:F10:H 2:A?:V".sub('?', (rand(8)+2).to_s),
     "5:F6:H 4:D5:V 3:E4:H 3:F9:H 2:!1:H".sub('!', (rand(9)+65).chr),
     "5:F10:H 4:B1:H 3:A2:V 3:A6:V 2:J?:V".sub('?', (rand(7)+1).to_s),
     "5:F1:V 4:A6:H 3:H6:H 3:F8:V 2:!?:V".sub('!', ['A','B','C','H','I','J'][rand 6]).sub('?', [1,2,8,9][rand 4].to_s),     
    ]
    options[rand options.length]
  end
  
  # Receives count
  # Returns space delimited positions. Such as "A1 J10"
  def shot(count)
    shots = (1..count).map do
      next_target || 'A1' # Out of shots already, just satisfy min-shots requirement
    end * ' '
    shots
  end
  
  # Expecting string: "A1:hit B10:miss"
  # Processes the result, marks the field appropriately, changes the sequence of shots accordingly.
  def process_shot_result(shot_result)
    shot_result.split(/:|\s/).each_slice(2) do |location, result|
      field[location] = result.to_sym      
      has_hit(location) if field[location] == :hit
    end
  end
  
  # Callback for an on-target shot
  def has_hit(hit)
    asap = []
    asap.push hit.to_left,  hit.to_left.to_left     if field[hit.to_right] == :hit
    asap.push hit.to_right, hit.to_right.to_right   if field[hit.to_left] == :hit
    asap.push hit.to_up,    hit.to_up.to_up         if field[hit.to_dn] == :hit
    asap.push hit.to_dn,    hit.to_dn               if field[hit.to_up] == :hit
    if asap.empty?
      # Force shooting around
      asap = [ hit.to_left,
        hit.to_right,
        hit.to_up,
        hit.to_dn
      ].reject { |l| l.nil? }      
    end
    asap.each { |l| @shot_queue.push l }
  end
end

