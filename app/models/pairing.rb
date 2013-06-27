# == Schema Information
#
# Table name: pairings
#
#  id         :integer          not null, primary key
#  user1_id   :integer
#  user2_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Pairing < ActiveRecord::Base
  include RedisKeyManager
  belongs_to :user1, class_name: 'User'
  belongs_to :user2, class_name: 'User'

  attr_accessible :user1_id, :user2_id

  after_create :send_email
  after_create :add_to_redis

private

  def send_email
    PairingsMailer.paired(self).deliver
  end

  def add_to_redis
    # Delete the user from the user's non paired list
    $redis.srem user_non_paired_teammates(user1.id), user2_id

    # Add to paired list with the created timestamp
    $redis.zadd user_pairings(user1.id), created_at.to_i, user2_id
  end

end
