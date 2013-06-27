# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'redis_key_manager'

class User < ActiveRecord::Base
  include RedisKeyManager

  attr_accessible :email, :name

  has_many :user_teams, class_name: 'UserTeams', dependent: :destroy
  has_many :teams, through: :user_teams

  has_many :pairings, dependent: :destroy, foreign_key: 'user1_id'

  validates :email,         presence: true,
                            format: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/,
                            uniqueness: true

  before_destroy :delete_pairings_redis

private

  def delete_pairings_redis
    $redis.del user_pairings(id)
    $redis.del user_non_paired_teammates(id)
  end

end
