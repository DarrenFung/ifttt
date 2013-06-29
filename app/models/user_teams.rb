# == Schema Information
#
# Table name: user_teams
#
#  id      :integer          not null, primary key
#  user_id :integer
#  team_id :integer
#

require 'redis_key_manager'

class UserTeams < ActiveRecord::Base
  include RedisKeyManager

  belongs_to :user
  belongs_to :team

  after_create :add_to_team_members
  after_create :add_to_non_paired
  before_destroy :remove_from_team_members

private

  def add_to_team_members
    # Add me to the team's members list
    $redis.sadd team_users(team_id), user.id
  end

  def add_to_non_paired
    # Unless I've been paired with the teammate
    # add me to his non paired list
    teammates = team.users.all
    teammates.delete user
    teammates.each do |t|
      if $redis.zscore(user_pairings(t.id), user.id).nil?
        $redis.sadd user_non_paired_teammates(t.id), user.id
      end

      # Do the same for myself
      if $redis.zscore(user_pairings(user.id), t.id).nil?
        $redis.sadd user_non_paired_teammates(user.id), t.id
      end
    end
  end

  def remove_from_team_members
    $redis.srem team_users(team_id), user.id
  end

end
