class Hand
  #<Artoo::Drivers::Leapmotion::Hand:0x007fd02d099b38 
  # @direction=[-0.0747336, 0.292273, -0.953411], 
  # @id=66, 
  # @palmNormal=[-0.821592, -0.559899, -0.107239], 
  # @palmPosition=[-246.876, 441.797, 193.875], 
  # @palmVelocity=[-369.385, 384.866, -718.654], @r=[[0.984894, 0.0351469, 0.169556], [-0.0419227, 0.998452, 0.0365478], [-0.168009, -0.043104, 0.984843]], 
  # @s=1, 
  # @sphereCenter=[-277.929, 458.442, 187.99], 
  # @sphereRadius=59.8973, 
  # @stabilizedPalmPosition=[-245.71, 440.514, 196.212], @t=[44.74, -20.5559, -12.4662], 
  # @timeVisible=13.867>

  DURATION_THRESHOLD = 500
  DRIFT_THRESHOLDS = 50
  COMMAND_CHANGE_THRESHOLD = 50
  KILL_THRESHOLD = 200
  
  def initialize(hand, direction)
    @direction = direction
    @palmpos = hand.stabilizedPalmPosition
    @prev_command = nil
    @prev_command_ts = Time.now
  end
  def process_hand(hand)
    palmpos = hand.stabilizedPalmPosition
    old_direction = @palmpos
    new_direction = palmpos
    diff = []
    old_direction.each_with_index do |value, index|
      diff[index] = new_direction[index] - value
    end
    # puts diff.inspect
    drift_value = diff.max_by(&:abs)
    abs_drift_value = drift_value.abs
    direction_index = diff.index drift_value
    
    if @direction == :right
      commands = [
        [:right, :left],
        [:up, :down],
        [:back, :front]
      ]
    else
      commands = [
        [:turn_right, :turn_left],
        [:unlock, :lock],
        [:beep, :beep]
      ]
    end
    direction_pair = commands[direction_index]
    return if abs_drift_value < DRIFT_THRESHOLDS
    
    if drift_value > 0
      command = direction_pair[0]
    else
      command = direction_pair[1]
    end
    if command != @prev_command && abs_drift_value < COMMAND_CHANGE_THRESHOLD 
      # tried palmvelocity
      # trying to check if you can only change command if previous command is atleast 0.5 seconds old

      return
    else

    end
    @palmpos = palmpos
    if command == @prev_command
      if Time.now - @prev_command_ts > 0.50
        trigger(command)
      end
    else
      if Time.now - @prev_command_ts > 0.2
        trigger(command)
      end
    end
  end
  
  def trigger(command)
    @prev_command = command
    # puts "Triggering ========================================= #{command}"
    $dr.send(command) if $dr.respond_to?(command)
  end
  
end