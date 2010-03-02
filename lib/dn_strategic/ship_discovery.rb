
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

