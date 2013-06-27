# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'redis_key_manager'

class Team < ActiveRecord::Base
  include RedisKeyManager

  has_many :user_teams, class_name: 'UserTeams'
  has_many :users, through: :user_teams

  before_destroy :delete_redis_key

  attr_accessible :name

private

  def delete_redis_key
    $redis.del team_users(id)
  end

end
