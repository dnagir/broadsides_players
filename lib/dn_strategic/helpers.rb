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
  %w{up dn left right}.each do |what|
    define_method("to_#{what}") do |*args|
      args[0]
    end
  end
end

