# {1=>[3, 4, 2, 6, 5], 2=>[6, 5, 4, 1, 3], 3=>[2, 4, 5, 1, 6], 4=>[5, 2, 3, 6, 1], 5=>[3, 1, 2, 4, 6], 6=>[5, 1, 3, 4, 2]}

# {1 => [8, 2 , 9 , 3 , 6 , 4 , 5 , 7 , 10], 2 => [4, 3, 8, 9, 5, 1, 10, 6, 7], 3 => [5, 6, 8, 2, 1, 7, 10, 4, 9], 4 => [10, 7, 9, 3, 1, 6, 2, 5, 8], 5 => [7, 4, 10, 8, 2, 6, 3, 1, 9], 6 => [2, 8, 7, 3, 4, 10, 1, 5, 9], 7 => [2, 1, 8, 3, 5, 10, 4, 6, 9], 8 => [10, 4, 2, 5, 6, 7, 1, 3, 9], 9 => [6, 7, 2, 5, 10, 3, 4, 8, 1], 10 => [3, 1, 6, 5, 2, 9, 8, 4, 7]}

# {1 => [2,6,4,3,5], 2 => [3,5,1,6,4], 3 => [1,6,2,5,4], 4 => [5,2,3,6,1], 5 => [6,1,3,4,2], 6 => [4,2,5,1,3]}

# {1 => [3,2,4], 2 => [4,3,1], 3 => [2,1,4], 4 => [1,3,2]}

# {1 => [2,4,3,5,6], 2 => [5,1,6,3,4], 3 => [5,6,1,4,2], 4 => [2,6,5,1,3], 5 => [1,4,3,6,2], 6 => [5,4,3,2,1]}

class StableMatcher

  def self.generate_random_set(count)
    raise unless count.even?

    hash = {}

    count.times do |c|
      a = []
      count.times { |t| a << (t+1) unless (t+1) == (c+1) }
      1.upto(count) do |i|
        j = rand(i + 1)
        a[i], a[j] = a[j], a[i]
      end
      hash[c+1] = a.compact
    end
    hash
  end

  attr_reader :matches

  # Expects preference_hash to be of format: { userId: [user_preferences] }
  def initialize(preference_hash)
    @preferences = {}
    preference_hash.each do |k,v|
      @preferences[k] = v.dup
    end

    check_input
    @matches     = {}
  end

  def start
    get_stable_matching

    @matches
  rescue
    raise "Not solvable"
  end

private

  def do_rotations
    while (rotation = find_rotation).size > 0 && !is_stable?
      apply_rotation(find_rotation)
    end

  end

  def find_rotation
    rotation = []
    @matches.each do |k,v|
      current_rotation = []
      next if is_matched?(k, v)
      current_proposer = k

      # Find the first person who would reject their current proposer for me
      current_fav      = @manipulated_preferences[current_proposer].detect { |val|
        is_better_match?(val, get_proposer(val), current_proposer) == current_proposer
      }

      # debugger

      # See if second favourite would reject their current proposal
      begin
        break if current_rotation.include?({current_proposer => current_fav})
        break if is_matched?(current_proposer, @matches[current_proposer])

        current_rotation << {current_proposer => current_fav}
        current_proposer = get_proposer(current_fav)
        current_fav      = @manipulated_preferences[current_proposer].detect { |val|
          is_better_match?(val, get_proposer(val), current_proposer) == current_proposer
        }
      end while current_proposer != k

      if current_proposer == k
        current_rotation.uniq!
        current_rotation.each do |r|
          r.each do |k,v|
            rotation << {k => @matches[k]}
          end
        end
        break
      end
    end
    rotation
  end

  def apply_rotation(rotation)
    rotation.each_with_index do |hash, i|
      @matches[hash.keys.first] = rotation[(i + 1) % rotation.size].values.first

      # debugger

      while @manipulated_preferences[hash.keys.first].include?(rotation[(i + 1) % rotation.size].values.first)
        @manipulated_preferences[hash.keys.first].shift
      end
    end
  end

  def get_stable_matching
    # First stage is each use proposes to their first choices
    propose_stage

    # If the match is stable, return it
    return if is_stable?

    # Otherwise, find rotations
    do_rotations
  end

  def propose_stage
    @matches                 = {}
    @manipulated_preferences = {}

    # Duplicate the preferences so we can modify it
    @preferences.each do |k,v|
      @manipulated_preferences[k] = v.dup
    end

    @manipulated_preferences.each do |key, preference_list|
      # Propose to everyone on the preference list until we find someone
      propose_to key.to_i, preference_list.shift
    end
  end

  def propose_to(first, second)
    if has_been_proposed?(second)
      # See who the better match is
      better_match = is_better_match?(second, first, get_proposer(second))

      # If i'm the better match, reject the other guy
      if better_match == first
        handle_rejection(second, first)
        @matches[first] = second
      else
        # Otherwise, keep moving down the preference list
        propose_to first, @manipulated_preferences[first].shift
      end
    else
      # Not already paired with someone.
      # So, pair up with this person
      @matches[first] = second
    end
  end

  def get_proposer(proposed)
    @matches.each do |k, v|
      return k if v == proposed
    end
    nil
  end

  def handle_rejection(rejector, rejecting_for)
    rejected           = get_proposer(rejector)

    # Now the rejected has to propose to next person
    propose_to rejected, @manipulated_preferences[rejected].shift
  end

  # See if a person already has been proposed to
  def has_been_proposed?(person)
    @matches.each do |_,v|
      return true if v == person
    end
    false
  end

  # For some person, see if first_better is the better match, or second_better
  # Returns the better match
  def is_better_match?(person, first_better, second_better)
    @preferences[person].detect { |pref| pref == first_better || pref == second_better }
  end

  def size
    @size ||= @preferences.keys.size
  end

  # Check if the matching found is a stable matching
  def is_stable?
    # Every person's partner should match up
    @matches.all? { |k,v| is_matched?(k, v) }
  end

  def is_matched?(person1, person2)
    @matches[person1] == person2 && @matches[person2] == person1
  end

  def check_input
    # Make sure the preference sizes all match
    unless @preferences.all? { |k,v| v.size == size - 1 }
      raise 'All arrays must have same size!'
    end

    # Ensure there's an even number of people
    raise "Must have even number of people" unless size.even?

  end

end
