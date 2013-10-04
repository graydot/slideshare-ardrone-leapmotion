class HandController
  def initialize
    @hand_list = {}
  end
  # receive a gesture and find if gesture already exists, update if not
  def process_hands(hands)
    if hands.length != 2
      puts "#{hands.length} hands detected" if hands.length > 2
      return
    end
      
    # check if these hands already exist, if not trigger right left detection
    @new_hands = false
    hand_diff = (@hand_list.keys - hands.collect(&:id)) + (hands.collect(&:id) - @hand_list.keys)
    if hand_diff.length > 0
      @new_hands = true
    end
    
    directions = {}
    directions = detect_hands(hands) if @new_hands
    hand_diff.each do |hid|
      @hand_list.delete(hid)
    end
    
    hands.each do |hand|
      process_hand(hand, directions[hand.id])
    end

  end
  
  # find left and right hand
  def process_hand(hand, direction)
    id = hand.id
    unless @hand_list[id]
      hand_obj = Hand.new(hand, direction)
      @hand_list[id] = hand_obj
    else
      @hand_list[id].process_hand(hand)
    end
  end
  
  def detect_hands(hands)
    f = hands.first
    s = hands.last
    
    hash = {}
    if f.stabilizedPalmPosition[0] > s.stabilizedPalmPosition[0]
      order = [:right, :left]
    else
      order = [:left, :right]
    end
    [f.id, s.id].each_with_index do |id, index|
      hash[id] = order[index]
    end
    return hash
  end
end