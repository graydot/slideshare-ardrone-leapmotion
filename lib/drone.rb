class Drone
  GROUND = 0
  AIR = 1
  MOVING = 2
  def initialize(drone)
    @drone = drone
    @state = GROUND
    # @output = false
    # @drone.nav_callback do |navdata|
    #   puts navdata.inspect unless @output
    #   @output = true
    # end
    $q = [:start]
  end
  def land
    $q = [:land]
  end
  
  def up
    if @state == GROUND
      $q = [:take_off]
      @state = AIR
    else
      $q = [:up, 2]
    end
  end
  
  def down
    return if @state == GROUND
    $q = [:down, 2]
  end
  def left
    return if @state == GROUND
    return
    $q = [:left, 2]
  end

  def right
    return if @state == GROUND
    return
    $q = [:right, 2]
  end

  def front
    return if @state == GROUND
    $q = [:forward, 2]
  end
    
  def back
    return if @state == GROUND
    $q = [:backward, 2]
  end
  def turn_right
    return if @state == GROUND
    $q = [:turn_right, 2]
  end
  def turn_left
    return if @state == GROUND
    $q = [:turn_left, 2]
  end
  def lock
    $q = [:lock]
  end
  def unlock
    $q= [:unlock]
  end
end