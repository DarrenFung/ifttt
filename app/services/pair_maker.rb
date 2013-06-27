require 'stable_matcher'
require 'redis_key_manager'

class PairMaker
  include RedisKeyManager

  def initialize
    @user_nonpaired_teammates = {}
    @user_paired_teammates    = {}
    @user_non_teammates       = {}
  end

  def get_pairs

    # First get all the teams including the users
    get_users
    handle_odd_case
    while (@matching = do_matching rescue nil).nil?
      # Set users to nil so we reshuffle
      @users = nil
      handle_odd_case
    end

    # Add a record for each of the matchings
    create_pairings
    @matching
  end

private

  def create_pairings
    Pairing.transaction do
      @matching.each do |k,v|
        Pairing.create(user1_id: k, user2_id: v)
      end
    end
    PairingsMailer.odd_pairing(@removed_user) unless @removed_user.nil?
  end

  def do_matching
    matcher = ::StableMatcher.new users
    matcher.start
  end

  def users
    return @users unless @users.nil?
    @users = {}
    User.select(:id).all.each do |u|
      next if u.teams.count == 0
      @users[u.id] = @user_nonpaired_teammates[u.id].shuffle + @user_paired_teammates[u.id] + @user_non_teammates[u.id].shuffle
    end
    @users
  end

  def handle_odd_case

    if users.size.odd?
      # We can't have an odd pair... so find someone to remove
      user_to_remove = Random.rand(users.size)
      user_id = users.keys[user_to_remove]
      users.delete(user_id)
      users.each do |k,v|
        v.delete(user_id)
      end

      @removed_user = User.find(user_id)
    end

  end

  def get_users
    all_users = User.select(:id).all.map &:id
    User.includes(:user_teams).select(:id).each do |u|

      if u.teams.count == 0
        all_users.delete u.id
        next
      end

      # Get the user's teams
      team_ids  = u.user_teams.map &:team_id
      team_keys = team_ids.map { |t| team_users(t) }

      # Get the teammates and assume they're non paired
      if team_keys.empty?
        @user_nonpaired_teammates[u.id] = []
      else
        @user_nonpaired_teammates[u.id] = $redis.sunion(team_keys).map &:to_i
        @user_nonpaired_teammates[u.id].delete u.id
      end

      # Get the paired teammates
      pairing_ids                     = $redis.zrangebyscore user_pairings(u.id), '-inf', '+inf'
      pairing_ids                     = pairing_ids.map &:to_i

      # This should really only include teammates, intersect the sets
      pairing_ids                     = pairing_ids & @user_nonpaired_teammates[u.id]

      # Remove the paired teammates from the non-paired teammates list
      @user_nonpaired_teammates[u.id] = @user_nonpaired_teammates[u.id] - pairing_ids

      @user_paired_teammates[u.id]    = pairing_ids
      user_teammates                  = @user_nonpaired_teammates[u.id] + @user_paired_teammates[u.id]

      # Get the non-teammates
      @user_non_teammates[u.id]       = all_users - user_teammates.map(&:to_i) - [u.id]
    end
  end

end
