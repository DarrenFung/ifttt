# == Schema Information
#
# Table name: user_teams
#
#  id      :integer          not null, primary key
#  user_id :integer
#  team_id :integer
#

class UserTeams < ActiveRecord::Base

  belongs_to :user
  belongs_to :team

  def self.get_teammates(user)
    team_ids = where(user_id: user).map &:team_id
    teams    = where(team_id: team_ids)
              .where(arel_table[:user_id].not_eq(user.id))
              .joins(:user)
    teams.map(&:user).uniq
  end

  def self.get_nonteammates(user)
    team_ids = where(user_id: user).map &:team_id
    teams    = where(arel_table[:team_id].not_in(team_ids))
              .where(arel_table[:user_id].not_eq(user.id))
              .joins(:user)
    teams.map(&:user).uniq
  end

end
