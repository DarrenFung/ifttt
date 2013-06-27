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
    @matching = do_matching

    # Add a record for each of the matchings
    create_pairings
    @matching
  end

private

  # def is_stable?
  #   return false if @matching.nil?
  #   # Make sure no user is paired with their last pair
  #   @matching.all? { |k,v| v != @user_paired_teammates[k].last }
  # end

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
      @users[u.id] = @user_nonpaired_teammates[u.id].shuffle + @user_paired_teammates[u.id] + @user_non_teammates[u.id].shuffle
    end
    @users
  end

  def handle_odd_case

    if users.size.odd?
      # We can't have an odd pair... so find someone to remove
      user_to_remove = Random.rand(users.size) + 1
      users.delete(user_to_remove)
      users.each do |k,v|
        v.delete(user_to_remove)
      end

      @removed_user = User.find(user_to_remove)

    end

  end

  def get_users
    all_users = User.select(:id).all.map &:id
    User.includes(:user_teams).select(:id).each do |u|
      # Get the user's teams
      team_ids  = u.user_teams.map &:team_id
      team_keys = team_ids.map { |t| team_users(t) }

      # Get the teammates and assume they're non paired
      @user_nonpaired_teammates[u.id] = $redis.sunion(team_keys).map &:to_i
      @user_nonpaired_teammates[u.id].delete u.id

      # Get the paired teammates
      pairing_ids = $redis.zrangebyscore user_pairings(u.id), '-inf', '+inf'
      pairing_ids = pairing_ids.map &:to_i

      # This should really only include teammates, intersect the sets
      pairing_ids = pairing_ids & @user_nonpaired_teammates[u.id]

      # Remove the paired teammates from the non-paired teammates list
      @user_nonpaired_teammates[u.id] = @user_nonpaired_teammates[u.id] - pairing_ids

      @user_paired_teammates[u.id] = pairing_ids
      user_teammates = @user_nonpaired_teammates[u.id] + @user_paired_teammates[u.id]

      # Get the non-teammates
      @user_non_teammates[u.id] = all_users - user_teammates.map(&:to_i) - [u.id]
    end
  end

end
