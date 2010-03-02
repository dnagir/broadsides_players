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

