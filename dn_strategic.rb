# Dmitriy Nagirnyak (dnagir at gmail dot com) for
#  the Ruby Challenge 7 (Broadsides)
#  http://rubylearning.com/blog/2010/02/23/rpcfn-broadsides-7


# Add small helpers to the String for grid navigation
class String

  # Returns the x-coordinate which is the letter on the board (B in B5)
  def x(from = 0)
    self[0,1][0] - 65 + from # 65.chr = 'A'
  end
  
  # Returns the y-coordinate which is the number on the board (5 in B5)
  def y(from = 0)
    self[1,2].to_i - 1 + from
  end

  def to_up(default = nil)
    pos = y(1)
    return default if pos == 1
    self[0,1] + pos.pred.to_s
  end
  
  def to_dn(default = nil)
    pos = y(1)
    return default if pos == 10
    self[0,1] + pos.succ.to_s
  end
  
  def to_left(default = nil)
    pos = x(65)
    return default if pos == 65
    pos.pred.chr + self[1,2]
  end
  
  def to_right(default = nil)
    pos = x(65)
    return default if pos == 74 # 'J'
    pos.succ.chr + self[1,2]
  end
end


# Just want to navigate to any side as much as I want with no worries: "A1".to_left.to_left => nil
class NilClass
  def to_up(default = nil)
    default
  end
  def to_dn(default = nil)
    default
  end
  def to_left(default = nil)
    default
  end
  def to_right(default = nil)
    default
  end
end


# Default random discovery of a ship.
class ShipDiscovery 
  def next
    generate_default_next
  end
  
  protected
  def generate_default_next
    @shots ||= (1..10).map { |y| ("A".."J").map { |x| "#{x}#{y}" } }.flatten.sort_by { rand }
    (@shots.push @shots.shift).last
  end
end

# Discovers ships by shooting at positions 'strategically'.
# This ensures all ships will hit with minimal number of shots.
class StepDiscovery < ShipDiscovery
  def initialize(guide_option = nil)
    super()
    @guide = []
    @guide.push 5,2,1,4,1,5,1,4,3,1 # 0
    @guide.push 1,5,4,1,3,1,5,3,1,2 # 1
    @guide.push 2,4,5,2,1,4,1,5,2,4 # 2
    @guide.push 4,1,2,5,4,1,3,1,5,1 # 3
    @guide.push 1,3,1,4,5,2,1,4,1,5 # 4
    @guide.push 5,1,4,1,2,5,4,1,3,1 # 5
    @guide.push 1,5,1,3,1,4,5,2,1,4 # 6
    @guide.push 4,1,5,1,4,1,2,5,4,1 # 7
    @guide.push 1,3,1,5,1,3,1,4,5,2 # 8
    @guide.push 2,1,4,1,5,1,4,2,1,5 # 9
    
    guide_option = rand(5) if guide_option == :transform
    @guide = case guide_option
      when 1
        @guide.reverse # Reverse the whole sequence
      when 2
        (0..9).map do |l|
           @guide[l*10, 10].reverse
         end.flatten # Reverse horizontally
      when 3
        (0..9).map do |col|
           (0..9).map { |l| @guide[l*10 + col] }.reverse
         end.flatten # Rotate right
      when 4
        (0..9).map do |col|
           (0..9).map { |l| @guide[l*10 + col] }
         end.reverse.flatten # Transpone
      else @guide
    end
  end  
  
  def next
    # Find the maximum element    
    ship_size = @guide.reject { |p| p == nil }.max || 0    
    available_positions = @guide.each_with_index.map { |p,i| p == ship_size ? i : nil }.compact
    return generate_default_next if available_positions.empty?
    next_pos = available_positions[rand available_positions.length]
    @guide[next_pos] = nil # Do not shot here anymore, been already    
    to_location next_pos    
  end
    
  private
    
  def to_location(pos)
    "#{(pos % 10 + 65).chr}#{pos / 10 + 1}"
  end
end

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

# 
# This line, required by the rules, ensures the server sees our responses as
# soon as they are written.
# 
$stdout.sync = true

me = Player.new

# The main loop
ARGF.each_line do |line|
  case line
  when /\AACTION SHIPS\b/
    puts "SHIPS #{me.allocate_ships}"
  when /\AACTION SHOTS (\d)/
    puts 'SHOTS ' + me.shot($1.to_i)
  when /\AINFO SHOTS (\w+) (.+)/
    if $1 == me.name
      me.process_shot_result $2
    end
  when /\AACTION FINISH\b/
    puts "FINISH"
  end
end

