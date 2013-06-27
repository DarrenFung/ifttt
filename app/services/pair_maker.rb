require 'stable_matcher'

class PairMaker

  def initialize
    @users              = {}
    @user_teammates     = {}
    @user_non_teammates = {}
  end

  def get_pairs

    # First get all the teams including the users
    get_users
    handle_odd_case
    matching = do_matching

    # Add a record for each of the matchings
    create_pairings(matching)
  end

private

  def create_pairings(matching)
    Pairing.transaction do
      matching.each do |k,v|
        Pairing.create(user1_id: k, user2_id: v)
      end
    end
    PairingsMailer.odd_pairing(@removed_user)
  end

  def do_matching
    matcher = ::StableMatcher.new @users
    matcher.start
  end

  def handle_odd_case

    if @users.size.odd?
      # We can't have an odd pair... so find someone to remove
      user_to_remove = Random.rand(@users.size) + 1
      @users.delete(user_to_remove)
      @users.each do |k,v|
        v.delete(user_to_remove)
      end

      @removed_user = User.find(user_to_remove)

    end

  end

  def get_users
    User.all.each do |u|
      # Get all ther user's teammates
      @users[u.id] = UserTeams.get_teammates(u).map &:id

      # Get the
      pairing_ids = Pairing.where(user1_id: u).order('created_at DESC').select(:user2_id).select('MAX(created_at) as created_at').uniq.group('user2_id').includes(:user2).map &:user2_id

      stack = []
      pairing_ids.each { |id|
        stack.unshift(id)
        @users[u.id].delete id
      }

      # Before we put the stack in, randomize the set
      @users[u.id].shuffle!
      @users[u.id].push *stack

      # Save this so we can randomize the right part later
      @user_teammates[u.id] = @users[u.id]

      @user_non_teammates[u.id] = UserTeams.get_nonteammates(u)
      puts u.id
      @user_non_teammates[u.id].each do |uu|
        @users[u.id].push(uu.id) unless @users[u.id].include?(uu.id)
      end
    end
  end

end
