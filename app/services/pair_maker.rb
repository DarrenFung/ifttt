require 'stable_matcher'

class PairMaker

  def initialize
    @users = {}
  end

  def get_pairs

    # First get all the teams including the users
    get_users
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
  end

  def do_matching
    matcher = ::StableMatcher.new @users
    matcher.start
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
      @users[u.id].push *stack

      non_teammates = UserTeams.get_nonteammates(u)
      non_teammates.each do |uu|
        @users[u.id].push(uu.id) unless @users[u.id].include?(uu.id)
      end
    end
  end

end
