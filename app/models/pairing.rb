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
  belongs_to :user1, class_name: 'User'
  belongs_to :user2, class_name: 'User'

  attr_accessible :user1_id, :user2_id

  after_create :send_email

private

  def send_email
    PairingsMailer.paired(self).deliver
  end

end
