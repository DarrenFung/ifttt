require 'stable_matcher'
require 'redis_key_manager'

class PairMaker
  include RedisKeyManager

  def initialize
    @user_nonpaired_teammates = {}
    @user_paired_teammates    = {}
    @user_non_teammates       = {}
    @all_users                = User.includes(user_teams: [:team]).select([:id, :email, :name])
  end

  def get_pairs

    # First get all the teams including the users
    get_users
    do_matching
    # Add a record for each of the matchings
    create_pairings
    @matching
  end

private

  def create_pairings
    # Group the users so we don't have to query every user
    users_hash = @all_users.group_by { |user| user.id }
    Pairing.transaction do
      @matching.each do |k,v|
        Pairing.create(user1: users_hash[k].first, user2: users_hash[v].first)
      end
    end
    PairingsMailer.odd_pairing(@removed_user) unless @removed_user.nil?
  end

  def do_matching

    while true
      begin
        handle_odd_case
        matcher   = ::StableMatcher.new users
        @matching = matcher.start
        break
      rescue ::StableMatcher::NoSolutionError
        @users = nil
      end
    end
  end

  def users
    return @users unless @users.nil?
    @users = {}
    all_users = @all_users.map &:id
    @all_users.each do |user|
      next if user.user_teams.length == 0
      @users[user.id] = @user_nonpaired_teammates[user.id].shuffle + @user_paired_teammates[user.id] + @user_non_teammates[user.id].shuffle

      # Remove non existant users
      @users[user.id] = @users[user.id] & all_users
    end
    @users
  end

  def handle_odd_case

    if users.size.odd?
      # We can't have an odd pair... so find someone to remove
      user_to_remove = Random.rand(users.size)
      user_id        = users.keys[user_to_remove]
      users.delete(user_id)
      users.each do |k,v|
        v.delete(user_id)
      end

      @removed_user = User.find(user_id)
    end

  end

  def get_users
    all_users = @all_users.map &:id
    @all_users.each do |user|

      # Delete users that don't belong to any team
      if user.user_teams.length == 0
        all_users.delete user.id
        next
      end

      # Get the user's teams
      team_ids  = user.user_teams.map &:team_id
      team_keys = team_ids.map { |t| team_users(t) }

      # Get the teammates and assume they're non paired
      if team_keys.empty?
        @user_nonpaired_teammates[user.id] = []
      else
        @user_nonpaired_teammates[user.id] = $redis.sunion(team_keys).map &:to_i
        @user_nonpaired_teammates[user.id].delete user.id
      end

      # Get the paired teammates
      pairing_ids                        = $redis.zrangebyscore user_pairings(user.id), '-inf', '+inf'
      pairing_ids                        = pairing_ids.map &:to_i

      # This should really only include teammates, intersect the sets
      pairing_ids                        = pairing_ids & @user_nonpaired_teammates[user.id]

      # Remove the paired teammates from the non-paired teammates list
      @user_nonpaired_teammates[user.id] = @user_nonpaired_teammates[user.id] - pairing_ids

      @user_paired_teammates[user.id]    = pairing_ids
      user_teammates                     = @user_nonpaired_teammates[user.id] + @user_paired_teammates[user.id]

      # Get the non-teammates
      @user_non_teammates[user.id]       = all_users - user_teammates.map(&:to_i) - [user.id]
    end
  end

end
